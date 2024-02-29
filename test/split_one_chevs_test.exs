defmodule Teiserver.Battle.SplitOneChevsTest do
  use ExUnit.Case, async: false
  alias Teiserver.Battle.Balance.SplitOneChevs.SplitOneChevsUtil
  alias Teiserver.Battle.Logger

  test "flatten members" do
    expanded_group = [
      %{count: 2, members: [100, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [17]}
    ]

    result =
      SplitOneChevsUtil.flatten_members(expanded_group)

    assert result == [
             %{rating: 8, rank: 4, member_id: 100},
             %{rating: 5, rank: 0, member_id: 4},
             %{rating: 6, rank: 0, member_id: 2},
             %{rating: 17, rank: 0, member_id: 3}
           ]
  end

  test "assign teams" do
    members = [
      %{rating: 8, rank: 4, member_id: 100},
      %{rating: 5, rank: 0, member_id: 4},
      %{rating: 6, rank: 0, member_id: 2},
      %{rating: 17, rank: 0, member_id: 3}
    ]

    result =
      SplitOneChevsUtil.assign_teams(members, 2)

    assert result == [
             %{
               members: [
                 %{rating: 17, rank: 0, member_id: 3},
                 %{rating: 8, rank: 4, member_id: 100}
               ],
               team_id: 1
             },
             %{
               members: [
                 %{rating: 6, rank: 0, member_id: 2},
                 %{rating: 5, rank: 0, member_id: 4}
               ],
               team_id: 2
             }
           ]
  end

  test "create empty teams" do
    result =
      SplitOneChevsUtil.create_empty_teams(3)

    assert result == [
             %{members: [], team_id: 1},
             %{members: [], team_id: 2},
             %{members: [], team_id: 3}
           ]
  end
end
