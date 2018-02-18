defmodule ResponseDiffTest do
  use ExUnit.Case
  alias ApiCanary.ResponseDiff
  alias ApiCanary.Request
  doctest ApiCanary.ResponseDiff

  test "make a basic health check" do
    assert %{} = ResponseDiff.make_diff( "https://api.openapi.ro/health_check", "true")
  end
  @anaf_v3_url "https://webservicesp.anaf.ro/PlatitorTvaRest/api/v3/ws/tva"
  
  test "Anaf expected with split tva correct date" do
    assert %{}==ResponseDiff.make_diff(
      %Request{
        url: @anaf_v3_url ,
        method: :post,
        headers: [{"Content-Type", "application/json"}],
        body: """
        [{"cui": 34892370, "data": "2017-09-29"}]
        """,
      },
      %{#expected response
        body: %{
          "cod"=>200,
          "found" => [
            %{"dataInceputSplitTVA" => "2017-10-01"}
          ]
        }
      }
      )
  end
  test "Anaf request with split tva" do
    ResponseDiff.make_diff(
      %Request{
        url: @anaf_v3_url ,
        method: :post,
        headers: [{"Content-Type", "application/json"}],
        body: """
        [{"cui": 34892370, "data": "2017-09-29"}]
        """,
      },
      %{#expected response
        body: %{
          "cod" => 200,
          "found" => [
            %{
              "adresa" => "MUNICIPIUL BUCUREŞTI, SECTOR 5, STR. NĂSĂUD, NR.74, BL.84, SC.1, ET.3, AP.13",
              "cui" => 34892370,
              "data" => "2017-09-29",
              "dataActualizareTvaInc" => "2015-11-13",
              "dataAnulareSplitTVA" => " ",
              "dataInactivare" => " ",
              "dataInceputSplitTVA" => "2017-09-29",
              "dataInceputTvaInc" => "2015-10-27",
              "dataPublicare" => " ",
              "dataPublicareTvaInc" => "2015-11-14",
              "dataRadiere" => " ",
              "dataReactivare" => " ",
              "dataSfarsitTvaInc" => "",
              "data_anul_imp_ScpTVA" => " ",
              "data_inceput_ScpTVA" => "2015-10-28",
              "data_sfarsit_ScpTVA" => " ",
              "denumire" => "TSD INTERNATIONAL SALES SRL",
              "mesaj_ScpTVA" => "platitor IN SCOPURI de TVA la data cautata",
              "scpTVA" => true,
              "statusInactivi" => false,
              "statusSplitTVA" => true,
              "statusTvaIncasare" => true,
              "tipActTvaInc" => "Inregistrare"
            }
          ],
          "message" => "SUCCESS",
          "notfound" => []
        }
      }
    )
  end
end
