defmodule Teiserver.Battle.SplitOneChevsTest do
  use ExUnit.Case, async: false
  alias Teiserver.Battle.Balance.SplitOneChevs.SplitOneChevsUtil

  test "flatten members" do
    expanded_group = [
      %{count: 2, members: [100, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [17]}
    ]

    result =
      SplitOneChevsUtil.flatten_members(expanded_group)

    IO.inspect(result, charlists: :as_lists)
  end

  test "assign teams" do
    members = [
      %{rating: 8, rank: 4, member_id: 100},
      %{rating: 5, rank: 0, member_id: 4},
      %{rating: 6, rank: 0, member_id: 2},
      %{rating: 17, rank: 0, member_id: 3}
    ]

    result =
      SplitOneChevsUtil.assign_teams(members)

    IO.inspect(result, charlists: :as_lists)
  end
end
