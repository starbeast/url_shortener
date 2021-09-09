import * as React from "react";
import { RouteHandler } from "./topLevelRouteHandlers";

export const UserDashboard: RouteHandler = (() => {
  const handler: any = () => {
    return (
      <div className="dashboard">

      </div>
    )
  };
  handler.route = '/';
  handler.exactRoute = true;
  handler.public = true;
  return handler;
})();
