# Outline

- Introduction
    - About Elm
    - About JSON Web Tokens
- Installing Elm
    - How to install Elm globally: `npm install -g elm`
    - How to create an Elm project: 
        - `elm package install`
    - Dependencies / build config
        - Update `elm-package.json`
        - Set up `gulp`
- Familiarizing with Elm language 
    - *Note:* this needs to just be a quick crash course with links to the docs, or this section will get way too long very quickly!
    - `elm-repl`
    - Typing, syntax, lack of truthiness
    - How functions work
    - If expressions
    - Records (like objects in JS)
- Hello World Elm app
    - Create a basic main view
    - Brief intro to `elm-reactor`
    - Viewing the app in browser (gulp server `localhost:3000`)
- How to call an API with Elm
    - Call unauthenticated route from [nodejs-jwt-authentication-sample](https://github.com/auth0-blog/nodejs-jwt-authentication-sample) GET `/api/random-quote`
- How to authenticate with JWT
    - Sign up form view and POST users `/users`
    - Create login view and POST to create session token `/sessions/create`
    - Save token to localStorage and verify authentication
    - Make authenticated API requests GET `/api/protected/random-quote`
    - Log out (remove token)
- ...etc
- Conclusion

## Considerations / Research / TODOs

- [x] Gulp
- [x] Foundation or Bootstrap? - Elm does not support external stylesheets well at this time
- [ ] Elm: How to make http requests? Management of subscriptions/promises?
- [ ] Elm: How to handle routing?

## Collected Resources

- Install the Elm language binaries: [https://www.npmjs.com/package/elm](https://www.npmjs.com/package/elm) `npm install -g elm`
- Elm tools [Get Started](http://elm-lang.org/get-started)
- [Documentation](http://elm-lang.org/docs) / [The Guide](http://guide.elm-lang.org/)
- [HTTP example](http://elm-lang.org/examples/http)
- [gulp-elm](https://www.npmjs.com/package/gulp-elm)