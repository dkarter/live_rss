defmodule LiveRSS.FeedMonitor do
  use GenServer

  alias LiveRSS.Feeds.Feed

  require Logger

  import SweetXml

  @interval 5 |> :timer.minutes()

  @spec start_link(Feed.t()) :: GenServer.on_start()
  def start_link(%Feed{} = feed) do
    name = feed.id |> to_string() |> via_tuple()
    GenServer.start_link(__MODULE__, feed, name: name)
  end

  @impl GenServer
  def init(%Feed{} = feed) do
    timer_ref =
      @interval
      |> :timer.send_interval(:check_feed)

    Logger.info("Starting feed monitor for #{feed.name}")

    {:ok, %{feed: feed, timer_ref: timer_ref}, {:continue, :check_feed}}
  end

  @impl GenServer
  def handle_continue(:check_feed, state) do
    send(self(), :check_feed)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:check_feed, state) do
    Logger.info("Checking feed: #{state.feed.name}")

    # TODO: this can be more efficient potentially with insert_all but then I'll
    # have to deal with placeholders to update the timestamps
    # also the current code crashes if one item fails to insert for some reason

    Req.new(url: state.feed.url)
    |> Req.request()
    |> case do
      {:ok, %Req.Response{status: 200, body: body}} ->
        body
        |> parse_response_items()
        |> Enum.each(fn item ->
          item
          |> Map.update!(:pub_date, &Timex.parse!(&1, "{RFC1123}"))
          |> Map.put(:feed_id, state.feed.id)
          |> LiveRSS.create_item()
        end)

      error ->
        Logger.error("Failed to get feed: #{state.feed.name}.\n#{inspect(error)}")
    end

    Logger.info("Done checking feed: #{state.feed.name}")
    {:noreply, state}
  end

  @spec find_pid(binary()) :: pid() | {atom(), atom()} | nil
  def find_pid(feed_id) do
    feed_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  @spec parse_response_items(map()) :: map()
  defp parse_response_items(response) do
    response
    |> xpath(~x"//channel/item"l,
      title: ~x"./title/text()"S,
      description: ~x"./description/text()"S,
      link: ~x"./link/text()"S,
      categories: ~x"./category/text()"Sl,
      guid: ~x"./guid/text()"S,
      pub_date: ~x"./pubDate/text()"S
    )
  end

  @spec via_tuple(binary()) :: {:via, Registry, {LiveRSS.FeedMonitorRegistry, binary()}}
  defp via_tuple(feed_id) do
    {:via, Registry, {LiveRSS.FeedMonitorRegistry, feed_id}}
  end
end
