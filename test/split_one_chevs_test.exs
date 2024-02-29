defmodule Teiserver.Battle.SplitOneChevsTest do
  use ExUnit.Case, async: false
  alias Teiserver.Battle.Balance.SplitOneChevs.SplitOneChevsUtil
  alias Teiserver.Battle.Logger

  test "perform" do
    expanded_group = [
      %{count: 2, members: [100, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [17]}
    ]

    result =
      SplitOneChevsUtil.perform(expanded_group, 2)

    assert result = %{

      team_groups: %{
        1 => [
          %{count: 1, members: [3], ratings: [17], group_rating: 17},
          %{count: 1, members: [100], ratings: [8], group_rating: 8}
        ],
        2 => [
          %{count: 1, members: [2], ratings: [6], group_rating: 6},
          %{count: 1, members: [4], ratings: [5], group_rating: 5}
        ]
      },
      ratings: %{1 => 25, 2 => 11},
      team_sizes: %{1 => 2, 2 => 2},
      means: %{1 => 12.5, 2 => 5.5},
      stdevs: %{1 => 4.5, 2 => 0.5},
      team_players: %{1 => [3, 100], 2 => [2, 4]},
      captains: %{1 => 3, 2 => 2},
      deviation: 56
    }

  end

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

  test "standardise result" do
    result = SplitOneChevsUtil.standardise_result(
      [
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
    )

    assert result ==%{
      ratings: %{1 => 25, 2 => 11},
      team_sizes: %{1 => 2, 2 => 2},
      team_groups: %{
        1 => [
          %{count: 1, members: [3], ratings: [17], group_rating: 17},
          %{count: 1, members: [100], ratings: [8], group_rating: 8}
        ],
        2 => [
          %{count: 1, members: [2], ratings: [6], group_rating: 6},
          %{count: 1, members: [4], ratings: [5], group_rating: 5}
        ]
      },
      means: %{1 => 12.5, 2 => 5.5},
      stdevs: %{1 => 4.5, 2 => 0.5},
      team_players: %{1 => [3, 100], 2 => [2, 4]},
      captains: %{1 => 3, 2 => 2},
      deviation: 56
    }
   end

  test "calculate standard deviation" do
    input = [8,5]
    result = Statistics.stdev(input);
    assert result==1.5
  end
end
