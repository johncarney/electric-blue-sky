# electric-blue-sky

TTRPG feed for Bluesky

# Goal

Provide a Bluesky feed of recent TTRPG-related posts.

## High-level requirements

- "TTRPG-related posts" means posts that include mentions of any number of
  TTRPG topics, including but not limited to:
  - Game systems such as *Dungeons & Dragons* and *Pathfinder*.
  - Actual Play shows like *Critical Role* and *Dimension 20*.
  - Settings such as *Forgotten Realms* and *Golarion*.
  - Podcasts like *The Gauntlet* and *The Glass Cannon*.
  - Creators like *Ginny Di*, *Questing Beast*, and *Seth Skorkowsky*.
  - Personalities like *Matt Mercer*, *Brennan Lee Mulligan*, and
    *Matt Colville*.
- The feed should consider image alt-text when scanning posts for terms.
- "Recent" means "within the last 48 hours." This may change depending on
  storage costs and other factors.
- An ability to report statistics on the feed, such as:
  - Number of posts in the feed.
  - Number of posts per topic.
  - Hourly breakdown of posts.
- The feed should be generated in real time.
- It is expected that new terms and topics will be updated on a not-infrequent
  basis (up to multiple times a day.)
- The feed should be generous in what it considers a match, but should have a
  low false-positive rate.
- The feed should consider replies, but it does not need to follow reply chains
  up.

### Possible future requirements

- Custom user feeds for an arbitrary set of topics
- The ability to exclude topics from custom feeds.
- Historical statistics.
- A web interface for viewing statistics.
- A web interface for viewing the feed.
- Include non-matching replies to, and re-posts of matching posts.

## Technical details

- This app is built using Ruby on Rails 7.x and Ruby 3.2.
- The app uses PostgreSQL 15.x for its database.
- Posts should be stored with maximum fidelity.
- Posts should be indexed as soon as possible upon ingestion.
- When terms and topics are updated, posts should be re-indexed. This
  re-indexing should only take minutes.

### Notes on technical details

With respect to indexing, experimentation has revealed that re-indexing on a
post-by-post basis is prohibitively slow. However, using PostgreSQL regular
expression searches to find posts that match given terms sufficiently fast to
achieved the desired re-indexing performance. Some care should be taken to find
the optimal index type.

For indexing posts on ingestion, it is expected that doing it entirely in Ruby
is the best approach.

Given that re-indexing will require a regular expression search over multiple
text fields within a single post, it is expected that it will be desirable to
de-normalize post text into a separate table.

To better support handling of replies and re-posts, it will probably be
necessary to de-normalize these as well, but that is a future requirement.
