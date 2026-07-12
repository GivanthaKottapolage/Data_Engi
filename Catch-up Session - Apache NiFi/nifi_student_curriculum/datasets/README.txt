These files back the sample flows:
- orders.json / coordinates.json are already embedded inline in the GenerateFlowFile
  processors, so most flows work immediately with no setup.
- incoming/*  -> copy this folder to /tmp/nifi_training/incoming for Flow 02 (ListFile demo)
  and /tmp/nifi_training/state_incoming for Flow 10 (state tracking demo).
- drivers_lookup.csv -> copy to /tmp/nifi_training/datasets/drivers_lookup.csv for Flow 09,
  or update the 'CSV File' property on the CSVRecordLookupService to wherever you place it.
- Flow 08 (database) expects an in-memory H2 database with an 'orders' table; you'll need the
  H2 driver jar available to NiFi and to create the table first, or repoint the DBCP service
  at your own database.
