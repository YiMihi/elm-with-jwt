import Html exposing (Html, button, div, text)
import Html.App as Html
import Html.Events exposing (onClick)

main : Program Never
main = 
    Html.beginnerProgram { model = model, view = view, update = update }
    
-- Model

type alias Model = String

model : Model
model =
    "Some quote"
    
-- Update

type Msg = AddA | AddB

update : Msg -> Model -> Model  
update msg model =
    case msg of
        AddA ->
            model ++ " A"
            
        AddB ->
            model ++ " B"
            
-- View

view : Model -> Html Msg
view model =
    div []
        [ button [ onClick AddA ] [ text "Add an A" ]
        , div [] [ text (toString model) ]
        , button [ onClick AddB ] [ text "Add a B" ]
        ]            