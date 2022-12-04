CREATE DATABASE IF NOT EXISTS praha_db_modering2 ;
use praha_db_modering2;

/* ==============================================*/
-- ユーザテーブル
CREATE TABLE users(
    email varchar(256) NOT NULL comment 'メールアドレス(IDの代わり)',
    name varchar(20) comment '氏名',
    PRIMARY KEY (email)
);

INSERT INTO users VALUES
  ('hogehoge1@gmail.com', '田中'),
  ('hugahuga2@gmail.com', '小林');

/* ==============================================*/

-- ユーザチャンネル所属履歴テーブル
CREATE TABLE IF NOT EXISTS user_channel_history (
    id int unsigned NOT NULL AUTO_INCREMENT,
    user_email varchar(256) NOT NULL comment 'ユーザID',
    channel_id int unsigned NOT NULL comment 'チャンネルID',
    join_at datetime NOT NULL comment 'チャンネル参加日時',
    leave_at datetime comment 'チャンネル脱退日時',
    PRIMARY KEY (id)
);

INSERT INTO user_channel_history VALUES
  (1, 'hogehoge1@gmail.com', 1, '2021-12-01 07:00:00', null),
  (2, 'hugahuga2@gmail.com', 1, '2022-08-01 07:00:00', null),
  (3, 'hogehoge1@gmail.com', 2, '2022-11-01 07:00:00', null);

/* ==============================================*/

-- メッセージテーブル
CREATE TABLE IF NOT EXISTS messages (
    id int unsigned NOT NULL AUTO_INCREMENT,
    channel_id int unsigned NOT NULL comment 'チャンネルID',
    user_history_id int unsigned NOT NULL comment 'ユーザ所属履歴ID',
    contents TEXT NOT NULL comment '内容',
    post_at datetime NOT NULL comment '投稿日時',
    PRIMARY KEY (id)
);

INSERT INTO messages VALUES
  (1, 1, 1,'こんにちは','2022-11-01 07:00:00'),
  (2, 1, 1,'スレッドへの返信文字列','2022-11-01 07:01:00'),
  (3, 2, 3,'テスト','2022-11-01 07:03:00');

/* ==============================================*/

-- スレッドテーブル
CREATE TABLE IF NOT EXISTS threads (
    id int unsigned NOT NULL AUTO_INCREMENT,
    message_id int unsigned NOT NULL comment 'メッセージID',
    channel_id int unsigned NOT NULL comment 'チャンネルID',
    user_history_id int unsigned NOT NULL comment 'ユーザ所属履歴ID',
    contents TEXT NOT NULL comment '内容',
    post_at datetime NOT NULL comment '投稿日時',
    PRIMARY KEY (id)
);

INSERT INTO threads VALUES
  (1, 1, 1, 1,'こんにちは２','2022-11-01 07:00:00'),
  (2, 2, 1, 1,'返信1','2022-11-01 07:02:00'),
  (3, 2, 1, 2,'テスト2','2022-11-01 07:03:00');

/* ==============================================*/

-- チャンネルテーブル
CREATE TABLE IF NOT EXISTS channels (
    id int unsigned NOT NULL AUTO_INCREMENT,
    name varchar(20) comment 'チャンネル名',
    PRIMARY KEY (id)
);

INSERT INTO channels VALUES
  (1, 'テストチャンネル1'),
  (2, 'テストチャンネル2');


/* ==============================================*/

-- 検証1:メッセージ詳細全体表示
with user_details as (
  select
    uch.id
    ,u.name username
    ,c.name channel_name
    ,uch.join_at
    ,uch.leave_at
  from user_channel_history uch
  left join users u
  on uch.user_email = u.email
  left join channels c
  on uch.channel_id = c.id
),
message_details as (
  select
    m.id message_id
    ,ud.channel_name
    ,ud.username
    ,m.contents message
    ,m.post_at message_post_at
  from messages m
  left join user_details ud
  on m.user_history_id = ud.id
),
thread_details as (
  select
    t.message_id
    ,ud.username
    ,t.contents thread_message
    ,t.post_at  thread_message_post_at
  from threads t
  left join user_details ud
  on t.user_history_id = ud.id
)
select * 
from message_details md
left join thread_details td
on md.message_id = td.message_id
;

-- 検証2:検索結果表示
select
  id message_id
  ,null thread_id
  ,user_history_id
  ,contents
  ,post_at
from messages
where contents like '%テスト%'

union

select
  message_id
  ,id thread_id
  ,user_history_id
  ,contents
  ,post_at
from threads
where contents like '%テスト%'
;
