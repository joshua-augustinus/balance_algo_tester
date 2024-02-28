defmodule Teiserver.Battle.SplitOneChevsTest do
  use ExUnit.Case, async: false
  alias Teiserver.Battle.Balance.SplitOneChevs.SplitOneChevsUtil

  test "one chev utils helper function" do
    expanded_group = [
      %{count: 2, members: [1, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [7]}
    ]

    result =
      SplitOneChevsUtil.flatten_members(expanded_group)

    IO.inspect(result, charlists: :as_lists)
  end
end
