# Profile — Kafka

**Read this when you add, change, or debug a Kafka consumer or producer.**

## Canonical documents

| Subject | Document |
|---|---|
| Topics this project consumes | `docs/knowledge/kafka-consumers.md` |
| Topics this project publishes | `docs/knowledge/kafka-topics-produced.md` |

Create the file the first time you need it. It is the single source of truth —
not the code comments, not the ticket.

## When you add a consumer

1. Add a row to `docs/knowledge/kafka-consumers.md`: consumer key, topic, class,
   purpose, startup behaviour.
2. Record the cluster if it is not the default one.
3. Record any filter the consumer applies — a tenant, a market, a message type.
   An undocumented filter looks like data loss to the next reader.
4. Update `updated:` in the frontmatter.

## When you change a consumer

Update the row in the same commit. A topic rename, a startup toggle, or a
cluster switch all change the row.

## When you add or change a producer

1. Update the table in `docs/knowledge/kafka-topics-produced.md`:
   topic, producing class or job, cluster, publication mode, known consumers.
2. **Find the consumers before you change anything.** A topic version bump or a
   schema change breaks every consumer. Search the consuming repositories listed
   in `docs/context/ecosystem.md`.
3. **Record the publication mode.** It decides whether a consumer recovers on
   its own after a lost message:

   | Mode | Self-healing | Cost |
   |---|---|---|
   | Full snapshot | Yes. The next run republishes everything. | High volume, lag spikes |
   | Snapshot plus explicit deletes | Upserts recover. Deletes do not. | Medium |
   | Changes only | No. A lost message stays lost until the record changes again. | Low volume, high risk |

4. **Read the mode from the publishing code.** Never from a changelog, a ticket,
   or a comment. Those drift.
5. Changing the publication mode is a contract change. Write an ADR.
6. Record the naming rules the producer applies: environment prefixes, version
   suffixes, and how a major version split works.

## Debugging checklist

- [ ] Is the consumer group committing? Check the lag per partition.
- [ ] Does the message have a key? A null key changes partitioning and can
      cause a retry loop.
- [ ] Is the offset reset policy what you expect on a new group?
- [ ] Is the failure in deserialization, in the handler, or in the commit?
- [ ] Does a poison message block the partition?

Record every new failure mode in `docs/lessons-learned/`.
