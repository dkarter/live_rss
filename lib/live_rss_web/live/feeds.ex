defmodule LiveRSSWeb.Feeds do
  use LiveRSSWeb, :live_view

  def mount(_params, _session, socket) do
    changeset = new_feed_changeset()
    feeds = load_feeds()

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:feeds, feeds)

    {:ok, socket}
  end

  def handle_event("save", %{"feed" => feed}, socket) do
    feed
    |> LiveRSS.Feed.changeset()
    |> LiveRSS.Repo.insert()
    |> case do
      {:ok, _feed} ->
        feeds = load_feeds()

        socket =
          socket
          |> assign(:feeds, feeds)
          |> assign(:changeset, new_feed_changeset())
          |> put_flash(:info, "Added new feed: #{feed["name"]}")

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, "Cannot save feed")

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"feed" => feed}, socket) do
    changeset =
      feed
      |> LiveRSS.Feed.changeset()
      # forces validation to show
      # see https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#module-a-note-on-errors
      |> Map.put(:action, :insert)

    socket =
      socket
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("delete", %{"value" => id}, socket) do
    LiveRSS.Feed
    |> LiveRSS.Repo.get(id)
    |> LiveRSS.Repo.delete()
    |> case do
      {:ok, _feed} ->
        feeds = load_feeds()

        socket =
          socket
          |> assign(:feeds, feeds)
          |> put_flash(:info, "Feed deleted successfully")

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, "Cannot delete feed: #{reason}")

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-lg font-semibold mb-3">Add Feed</h2>
      <.simple_form
        :let={f}
        for={@changeset}
        phx-change="validate"
        phx-submit="save"
        class="[&>div]:mt-0"
      >
        <div class="md:flex md:space-x-4 md:[&>div:last-child]:grow">
          <.input field={{f, :name}} label="Name" />
          <.input field={{f, :url}} label="URL" />
        </div>
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>

      <h2 class="text-lg font-semibold mt-8 mb-3">Feeds</h2>

      <p :if={length(@feeds) == 0} class="italic">No feeds found, add one now!</p>

      <.table :if={length(@feeds) > 0} id="feeds" rows={@feeds}>
        <:col :let={feed} label="id"><%= feed.id %></:col>
        <:col :let={feed} label="name"><%= feed.name %></:col>
        <:col :let={feed} label="url"><%= feed.url %></:col>
        <:col :let={feed} label="actions">
          <.button value={feed.id} phx-click="delete" alt="delete feed" class="bg-transparent">
            <Heroicons.trash mini class="mt-0.5 h-5 w-5 flex-none fill-rose-500" />
          </.button>
        </:col>
      </.table>
    </div>
    """
  end

  defp new_feed_changeset do
    LiveRSS.Feed.changeset(%{})
  end

  defp load_feeds do
    LiveRSS.Feed |> LiveRSS.Repo.all()
  end
end
