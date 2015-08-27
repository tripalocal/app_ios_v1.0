DROP TABLE IF EXISTS "messageList";
CREATE TABLE "messageList" ("local_id" INTEGER PRIMARY KEY  NOT NULL  UNIQUE , "receiver_id" INTEGER NOT NULL , "msg_content" TEXT NOT NULL , "msg_date" TEXT NOT NULL );
