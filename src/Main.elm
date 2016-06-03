module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Task exposing (Task)
import Json.Decode as Json

main : Program Never
main = 
    Html.program 
        { init = init 
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
    
-- Model

type alias Model =
    {
        username : String
        , password : String
        , token : String
        , quote : String
        , protectedQuote : String
        , message : String
    }
    
init : (Model, Cmd Msg)
init =
    (Model "" "" "" "Men are like steel. When they lose their temper, they lose their worth." "" "", Cmd.none)
    
-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error
    | Username String
    | Password String
    | RegisterUser
    | RegisterUserSuccess
    
api : String
api =
     "http://localhost:3001/api/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "random-quote"
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote  
    
registerUrl : String
registerUrl =
    api ++ "users" 
    
registerUser : Model -> Platform.Task Http.Error (Maybe String)
registerUser model =
    let 
        body = Http.multipart
            [ Http.stringData "username" model.username
            , Http.stringData "password" model.password
            ]
    in 
        Http.post (Json.maybe Json.string) registerUrl body
        --|> Task.map getToken
        |> Task.perform HttpError RegisterUserSuccess registerUser
                    
               
-- View

view : Model -> Html Msg
view model =
    div [ class "container row text-center" ] [
        h2 [] [ text "Chuck Norris Quotes" ]
        , button [ class "btn btn-primary", onClick GetQuote ] [ text "Grab a quote!" ]
        , blockquote [ class "text-left" ] [ 
            p [] [text model.quote] 
        ]
        , Html.form [ id "form", class "text-left" ] [
            h3 [ class "text-center" ] [ text "Register or Log In" ]
            , div [ class "form-group row" ] [
                div [ class "col-md-offset-4 col-md-4" ] [
                    label [ for "username" ] [ text "Username:" ]
                    , input [ id "username", type' "text", class "form-control", onInput Username ] []
                ]    
            ]
            , div [ class "form-group row" ] [
                div [ class "col-md-offset-4 col-md-4" ] [
                    label [ for "password" ] [ text "Password:" ]
                    , input [ id "password", type' "password", class "form-control", onInput Password ] []
                ]    
            ]
            , button [ class "btn btn-primary", onClick RegisterUser ] [ text "Register" ]
            --, button [ class "btn btn-secondary", onClick LogIn ] [ text "Log In" ]
        ]
    ]
    
-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
    case action of
        GetQuote ->
            (model, fetchRandomQuoteCmd)
        FetchQuoteSuccess newQuote ->
            ({ model | quote = newQuote }, Cmd.none)
        HttpError _ ->
            (model, Cmd.none)   
        Username username ->
            ({ model | username = username }, Cmd.none)
        Password password ->
            ({ model | password = password }, Cmd.none)
        RegisterUser ->
            (model, registerUser model)
        RegisterUserSuccess ->
            ({ model | token = "yay" }, Cmd.none)    
        --GetToken ->
                
    
-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.none