defmodule Teiserver.Battle.CaptainTest do
  use ExUnit.Case, async: false
  alias Teiserver.Battle.BalanceLib
  alias Teiserver.Battle.Logger

  test "captain test with groups" do
    result =
      BalanceLib.get_captain([
        %{
          count: 3,
          ratings: [19, 16, 16],
          members: [112, 113, 114],
          group_rating: 51
        },
        %{count: 2, ratings: [14, 8], members: [115, 116], group_rating: 22},
        %{count: 1, ratings: [41], members: [101], group_rating: 41},
        %{count: 1, ratings: [26], members: [109], group_rating: 26},
        %{count: 1, ratings: [21], members: [111], group_rating: 21}
      ])
  end

  test "loser picks bigger game group" do
    result =
      BalanceLib.create_balance(
        [
          # Two high tier players partied together
          %{101 => 41, 102 => 35},

          # A bunch of mid-low tier players together
          %{103 => 20, 104 => 17, 105 => 13.5},

          # A smaller bunch of even lower tier players
          %{106 => 15, 107 => 7.5},

          # Other players, a range of ratings
          %{108 => 31},
          %{109 => 26},
          %{110 => 25},
          %{111 => 21},
          %{112 => 19},
          %{113 => 16},
          %{114 => 16},
          %{115 => 14},
          %{116 => 8}
        ],
        2,
        mode: :loser_picks,
        rating_lower_boundary: 5,
        rating_upper_boundary: 5,
        mean_diff_max: 5,
        stddev_diff_max: 5
      )

    assert Map.drop(result, [:logs, :time_taken]) == %{
             captains: %{1 => 101, 2 => 102},
             deviation: 2,
             ratings: %{1 => 161, 2 => 164},
             team_groups: %{
               1 => [
                 %{count: 3, group_rating: 51, members: [112, 113, 114], ratings: [19, 16, 16]},
                 %{count: 2, group_rating: 22, members: [115, 116], ratings: [14, 8]},
                 %{count: 1, group_rating: 41, members: [101], ratings: [41]},
                 %{count: 1, group_rating: 26, members: [109], ratings: [26]},
                 %{count: 1, group_rating: 21, members: [111], ratings: [21]}
               ],
               2 => [
                 %{
                   count: 3,
                   group_rating: 50.5,
                   members: [103, 104, 105],
                   ratings: [20, 17, 13.5]
                 },
                 %{count: 2, group_rating: 22.5, members: [106, 107], ratings: [15, 7.5]},
                 %{count: 1, group_rating: 35, members: [102], ratings: [35]},
                 %{count: 1, group_rating: 31, members: [108], ratings: [31]},
                 %{count: 1, group_rating: 25, members: [110], ratings: [25]}
               ]
             },
             team_players: %{
               1 => [112, 113, 114, 115, 116, 101, 109, 111],
               2 => [103, 104, 105, 106, 107, 102, 108, 110]
             },
             team_sizes: %{1 => 8, 2 => 8},
             means: %{1 => 20.125, 2 => 20.5},
             stdevs: %{1 => 9.29297449689818, 2 => 8.671072598012312}
           }
  end
end
