import * as React from "react";
import { Main } from "./Main";
import { UserDashboard } from "./UserDashboard";

export type RouteHandler = React.FunctionComponent<any> & {
  route: string;
  exactRoute?: boolean;
  public?: boolean;
};

export const topLevelRouteHandlers: RouteHandler[] = [Main, UserDashboard];
