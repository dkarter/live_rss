defmodule LiveRSS.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field :name, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(feed \\ %__MODULE__{}, attrs) do
    feed
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> validate_length(:name, min: 2)
  end
end
