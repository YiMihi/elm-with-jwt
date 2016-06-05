module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Http
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

main : Program Never
main = 
    Html.program 
        { init = init 
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
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
    | ClickRegisterUser
    | RegisterUserSuccess String
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote  
    
registerUrl : String
registerUrl =
    api ++ "users"
 
{-    
resDecoder : Decode.Decoder (List String)
resDecoder = 
    Decode.list Decode.string
-}     
    
tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string
    
userEncoder : Model -> Encode.Value
userEncoder model = 
    Encode.object 
        [("username", Encode.string model.username)
        , ("password", Encode.string model.password)]    
    
registerUser : Model -> Task Http.Error (String)
registerUser model =
    {
        verb = "POST"
        , headers = [ ("Content-Type", "application/json") ]
        , url = registerUrl
        , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder
    
registerUserCmd : Model -> Cmd Msg
registerUserCmd model =
    Task.perform HttpError RegisterUserSuccess <| registerUser model
                    
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
        ClickRegisterUser ->
            (model, registerUserCmd model)
        RegisterUserSuccess newToken ->
            ({ model | token = newToken }, Cmd.none)    
                       
-- View

view : Model -> Html Msg
view model =
    div [ class "container row text-center" ] [
        h2 [] [ text "Chuck Norris Quotes" ]
        , button [ class "btn btn-primary", onClick GetQuote ] [ text "Grab a quote!" ]
        , blockquote [ class "text-left" ] [ 
            p [] [text model.quote] 
        ]
        , div [ id "form", class "text-left" ] [
            h3 [ class "text-center" ] [ text "Log In or Register" ]
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
            , div [ class "text-center" ] [
                button [ class "btn btn-primary" ] [ text "Log In" ]
                , button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
            ] 
        ]
    ]