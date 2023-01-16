defmodule LiveRSS do
  @moduledoc """
  LiveRSS keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias LiveRSS.Feeds
  alias LiveRSS.FeedMonitorSupervisor

  defdelegate create_feed(attrs), to: Feeds

  defdelegate delete_feed(id), to: Feeds

  defdelegate get_feed(id), to: Feeds

  defdelegate list_feeds, to: Feeds

  defdelegate start_feed_monitor(feed), to: FeedMonitorSupervisor

  defdelegate stop_feed_monitor(feed_id), to: FeedMonitorSupervisor

  defdelegate is_feed_monitor_running?(feed_id), to: FeedMonitorSupervisor
end
