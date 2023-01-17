defmodule LiveRSS.Items do
  alias LiveRSS.Items.Item
  alias LiveRSS.Repo

  def create_item(attrs) do
    attrs
    |> Item.changeset()
    |> Repo.insert(
      on_conflict: :nothing,
      conflict_target: [:feed_id, :guid]
    )
  end
end
