defmodule OnlyExpectedKeysTest do
  use ExUnit.Case
  import ApiCanary.ResponseDiff
  test "gkeep_only_keys" do
    assert %{b: 2} ==  keep_only_keys(%{b: 3}, %{a: 1,b: 2,c: 3})
    assert %{b: [2]} ==  keep_only_keys(%{b: [3]}, %{a: 1,b: [2,3],c: 3})
    assert %{b: [%{val: 2}]} ==  keep_only_keys(%{b: [%{val: nil}]}, %{a: 1,b: [%{val: 2},3],c: 3})
    assert %{b: [%{}]} ==  keep_only_keys(%{b: [%{other_val: nil}]}, %{a: 1,b: [%{val: 2},3],c: 3})
  end
end
