import * as React from "react";
import { Route, RouteProps } from "react-router-dom";
import { isAuthenticated } from "../utils/auth";
import { Main } from "./Main";
import { RouteHandler } from "./topLevelRouteHandlers";

interface PrivateRouteProps extends RouteProps {
  handler: RouteHandler;
}

export const PrivateRoute = (props: PrivateRouteProps) => {
  const { handler: Handler, ...restProps } = props;
  const authenticated = isAuthenticated();

  if (!authenticated) {
    window.location.replace(Main.route);
    return null;
  }

  const routeProps: RouteProps = {
    ...restProps,
    path: Handler.route,
    exact: Handler.exactRoute,
  };

  return (
    <Route {...routeProps}>
      <Handler />
    </Route>
  );
};
