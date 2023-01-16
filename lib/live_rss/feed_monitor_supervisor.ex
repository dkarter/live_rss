defmodule LiveRSS.FeedMonitorSupervisor do
  @moduledoc """
  Supervises workers that read feeds
  """

  use DynamicSupervisor

  alias LiveRSS.Feeds.Feed
  alias LiveRSS.FeedMonitor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init([]) do
    # TODO: how can I have this boot up with all the feeds in the database when the
    # app starts?
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_feed_monitor(Feed.t()) :: DynamicSupervisor.on_start_child()
  def start_feed_monitor(%Feed{} = feed) do
    child_spec = %{
      id: FeedMonitor,
      start: {FeedMonitor, :start_link, [feed]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @spec stop_feed_monitor(binary() | number()) :: :ok
  def stop_feed_monitor(feed_id) do
    feed_id
    |> to_string()
    |> FeedMonitor.find_pid()
    |> case do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        :ok

      nil ->
        :ok
    end
  end

  @spec is_feed_monitor_running?(number() | binary()) :: boolean()
  def is_feed_monitor_running?(feed_id) do
    feed_id
    |> to_string()
    |> FeedMonitor.find_pid()
    |> is_pid()
  end
end
