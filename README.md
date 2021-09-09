# README

To start the app

```
$ docker-compose build
$ docker-compose up
$ docker-compose run web bundle exec rake db:create
$ docker-compose run web bundle exec rake db:migrate
```

You can modify `docker-compose.yml` in case your local docker-compose version doesn't match
the one defined in the compose file

the API can be accessed on localhost:3000

To start the FE
```
npm start
```
and then open the UI on localhost:3001

## Design decisions

There are two ways to make requests to user scoped protected endpoints: either by having a session cookie in your request or by defining the Authorization header with a user's API key as its value.

Obvious bottleneck of the problem is unique shortened urls generation. The approach of the solution is to create paths for shortened urls in advance and store them in cache (and fill it with new values periodically).

Cache is implemented as a simple Redis set and is managed by sidekiq periodic job filling it with up to 5k shortened paths (it doesn't really have to be 5k and can be easily made a dynamic value with some hard limit based on available memory and soft limit defined by the current usage of the API - a sliding window in Redis can be used to track the amount of shortenings performed between the generation cycles and we can adjust the number of generated fragment based on this value).
Url paths themselves are 10-character alphanumeric strings which gives us up to 36**10 unique paths. Redis cache only guarantees paths to be unique in its currently generated chunk, paths are forced to be globally unique by handling a unique index on the corresponding column in PG. 
