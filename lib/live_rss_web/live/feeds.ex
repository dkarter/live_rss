defmodule LiveRSSWeb.Feeds do
  use LiveRSSWeb, :live_view

  def mount(_params, _session, socket) do
    changeset = new_feed_changeset()
    feeds = LiveRSS.Feed |> LiveRSS.Repo.all()

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
        feeds = LiveRSS.Feed |> LiveRSS.Repo.all()

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
        feeds = LiveRSS.Feed |> LiveRSS.Repo.all()

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
      <.simple_form :let={f} for={@changeset} phx-change="validate" phx-submit="save">
        <.input field={{f, :name}} label="Name" />
        <.input field={{f, :url}} label="URL" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>

      <.table id="feeds" rows={@feeds}>
        <:col :let={feed} label="id"><%= feed.id %></:col>
        <:col :let={feed} label="name"><%= feed.name %></:col>
        <:col :let={feed} label="url"><%= feed.url %></:col>
        <:col :let={feed} label="actions">
          <.button value={feed.id} phx-click="delete">Delete</.button>
        </:col>
      </.table>
    </div>
    """
  end

  defp new_feed_changeset do
    LiveRSS.Feed.changeset(%{})
  end
end
