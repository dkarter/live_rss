defmodule LiveRSS.FeedMonitor do
  use GenServer

  alias LiveRSS.Feeds.Feed

  require Logger

  @spec start_link(Feed.t()) :: GenServer.on_start()
  def start_link(%Feed{} = feed) do
    name = feed.id |> to_string() |> via_tuple()
    GenServer.start_link(__MODULE__, feed, name: name)
  end

  @impl GenServer
  def init(%Feed{} = feed) do
    timer_ref =
      :timer.minutes(1)
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
    # request feed
    # parse the feed
    # store articles in database (unless already stored)
    Logger.info("Checking feed: #{state.feed.name}")

    Req.new(url: state.feed.url)
    |> Req.request()
    |> case do
      {:ok, %Req.Response{status: 200, body: body}} ->
        dbg(body)

      otherwise ->
        dbg(otherwise)
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

  @spec via_tuple(binary()) :: {:via, Registry, {LiveRSS.FeedMonitorRegistry, binary()}}
  defp via_tuple(feed_id) do
    {:via, Registry, {LiveRSS.FeedMonitorRegistry, feed_id}}
  end
end
