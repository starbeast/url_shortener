import * as React from "react";
import { BrowserRouter, Redirect, Route, Switch } from "react-router-dom";
import { hot } from "react-hot-loader";
import "./../assets/scss/App.scss";
import { Main } from "../routes/Main";
import { PrivateRoute } from "../routes/PrivateRoute"
import { topLevelRouteHandlers } from "../routes/topLevelRouteHandlers";

export const App = () => {
  return (
    <BrowserRouter>
      <Switch>
        {topLevelRouteHandlers.map(handler =>
          handler.public ? (
            <Route
              key={handler.route}
              path={handler.route}
              component={handler}
              exact={handler.exactRoute}
            />
          ) : (
            <PrivateRoute
              key={handler.route}
              path={handler.route}
              handler={handler}
            />
          ),
        )}
        <Redirect to={Main.route} />
      </Switch>
    </BrowserRouter>
  )
};

declare let module: Record<string, unknown>;

export default hot(module)(App);
