bill.im API 문서
===============

이 문서에서는 bill.im의 API에 대해 다룹니다.

통신 방법
=======

클라이언트 -> 서버 (Upstream)
--------------------------

클라이언트와 서버가 기본적으로 통신하는 데에는 HTTP를 사용합니다.

클라이언트에서 서버로 데이터를 보낼 때에는 QueryString(POST)를 사용해 직렬화합니다.
하지만 서버에서 클라이언트에게 데이터를 돌려줄 때에는 JSON을 사용해 직렬화합니다.

요청에는 POST 요청만을 사용합니다. GET 요청은 사용되지 않습니다.

서버 -> 클라이언트 (Downstream)
----------------------------

서버가 클라이언트에게 푸시 알림을 전송하는데는 
[Google Cloud Messaging](https://developers.google.com/cloud-messaging)을
사용합니다.

서버에서는 GCM 서버에 HTTP를 사용해 클라이언트에게 알림을 보내달라고 전송하게 됩니다.

서버에서는 클라이언트상에서 표시해야 할 notification 정보를 그대로 전송합니다. 따로
메시지를 해독할 필요는 없습니다. **아직 불확실함**

클라이언트의 구현방법은
[여기](https://developers.google.com/cloud-messaging/android/client)를
참조해 주세요.

클라이언트는 자신의 `token`을 서버로 보내야 푸시 알림이 작동합니다. 
자세한 사항은 이 문서의 **WIP**를 참조해 주세요.

인증
===

bill.im은 API 토큰 기반 인증을 사용합니다. 클라이언트가 인증 방법 중 하나를 사용해 로그인
하게 되면 서버는 해당 유저에게 속하는 API 토큰을 보냅니다.

~~API 토큰이 expire되는 것도 구현해야 하지만 귀찮으므로 생략~~

API 토큰은 클라이언트가 저장하고 있어야 하며 외부에서 접근 가능하면 안됩니다.

서버에서 관리하는 '유저'는 한 인증 방법에 종속됩니다. 즉, Facebook 로그인을 사용하다가
아이디/비밀번호 방식의 로그인으로 바꿀 수 없습니다. ~~귀찮아서요.~~

인증 방법
--------

여기서는 클라이언트가 자격 증명을 얻기 위해 사용 가능한 인증 방법에 대해 서술합니다.

### Facebook 로그인

[서버 API](https://github.com/drudge/passport-facebook-token)

[클라이언트 API](https://developers.facebook.com/docs/facebook-login/android/v2.3)

Facebook 로그인이 클라이언트 상에서 처리되면 클라이언트는 서버의 
`/api/auth/facebook/token`으로 `access_token`에 AccessToken을 담은 POST 전송을 
보냅니다.

서버는 인증이 실패했는지 성공했는지 판단하고 그에 맞는 대답을 보냅니다. 
자세한 사항은 이 문서의 **WIP**를 참조해 주세요.

### Google+ 로그인

[서버 API](https://github.com/ghaiklor/passport-google-plus-token)

[클라이언트 API](https://developers.google.com/+/mobile/android/sign-in)

[AccessToken 가져오기](http://stackoverflow.com/q/18096934/3317669)

클라이언트 개발자님 힘내세요. (으아아악)

API 인증
--------

`/api/auth` 외의 거의 대부분의 API는 인증을 필요로 하고 이 인증은 API 토큰으로 이루어집니다.

API 토큰을 `token`에 넣어서 POST 요청을 보낼 때 같이 보내면 인증이 자동으로 처리됩니다.

데이터베이스 스키마
================

여기서는 bill.im에 사용되는 데이터베이스 스키마를 다룹니다.

이 데이터베이스 스키마는 내부적으로도 사용되고 외부로 노출된 API에서도 그대로 사용됩니다.

User
----

사용자 하나를 의미합니다.

### id

int, primary key. 사용자의 고유 번호입니다.

### name

String, not null. 사용자의 이름입니다.

### phone

String. 사용자의 전화번호입니다.

### description

String. 사용자의 간단한 자기소개입니다.

### groups

Group[]. 사용자가 속하고 있는 그룹들입니다.

### enabled

Boolean, not null. 사용자의 활성 상태입니다.

### token

String. 사용자의 API 토큰입니다.

### auth

Object. 사용자의 인증 수단에 관한 정보입니다.

Group
-----

사용자들이 속하는 단체 하나를 의미합니다.

### id

int, primary key. 단체의 고유 번호입니다.

### name

String, not null. 단체의 이름입니다.

### description

String. 단체의 설명입니다. **기획서에는 안나와 있는듯**

Article
-------

작성된 게시글 (빌려주세요/빌려드려요/교환해요) 하나를 의미합니다.

### id

int, primary key. 게시글의 고유 번호입니다. 

### group

Group, not null. 이 게시글이 종속된 단체입니다.

### type

int, not null. 다음 값 중 하나입니다.

- 0 - 빌려주세요
- 1 - 교환해요

### state

int, not null. 이 게시글의 상태입니다.

- 0 - 대기 중
- 1 - 거래 완료
- 2 - 삭제됨

### name

String, not null. 타겟 물건의 이름입니다.

타겟 물건은 다음 중 하나를 의미합니다:

- 빌려주세요 - 글쓴이가 빌리고 싶은 물건을 의미합니다.
- 빌려드려요 - 글쓴이가 빌려주는 물건을 의미합니다.
- 교환해요 - 글쓴이가 얻고 싶은 물건을 의미합니다.

### description

String, not null. 게시글의 설명입니다.

### reward

String, not null. 예상되는 보상입니다.

교환해요 게시글의 경우에는 이 필드가 글쓴이가 주는 물건(더이상 필요 없는 물건)을 의미합니다.

### location

String. 예상되는 거래 위치입니다.

### author

User, not null. 이 게시글을 작성한 사용자입니다.

### transaction

Transaction, null. 이 게시글이 종속된 거래 요청입니다. 아직 거래가 성립되지 않은 경우
null로 설정됩니다.

Comment
-------

게시글에 달린 댓글 하나를 의미합니다.

### id

int, primary key. 댓글의 고유 번호입니다.

### description

String, not null. 댓글의 내용입니다.

### author

User, not null. 이 게시글을 작성한 사용자입니다.

### secret

Boolean, not null. 이 댓글이 비밀 댓글인지의 여부입니다.

### article

Article, not null. 이 댓글이 종속된 게시글입니다.

### reply

User, not null. 비밀 글일 경우 이 비밀 글이 보일 유저를 설정합니다.

### transaction

Transaction, null. 이 댓글이 거래 요청 댓글일 경우 종속된 거래 요청을 설정합니다.

Transaction
-----------

현재 진행 중인 거래 하나를 의미합니다.

### id

int, primary key. 거래의 고유 번호입니다.

### requester

User, not null. 게시글을 쓴 사람입니다.

### responder

User, not null. 거래를 제안한 사람입니다. (게시글을 쓴 사람의 반대)

### article

Article, not null. 이 거래가 종속된 게시글입니다.

### state

int, not null. 이 거래의 상태입니다.

- 0 - 게시글 작성자의 응답을 기다리는 상태 (대기)
- 1 - 거절
- 2 - 삭제
- 3 - 승인
- 4 - 빌려줌
- 5 - 완료

### reward

String, not null. 이 거래의 보상입니다.

### location

String, not null. 교환하는 위치입니다.

API 레퍼런스
===========

오류 처리
--------

오류가 발생했는지 여부는 'code' 값으로 확인할 수 있습니다.

- 200 - 성공적으로 실행 함
- 400 - 입력받은 데이터가 잘못 됨
- 401 - 로그인 필요
- 403 - 권한 없음
- 422 - 데이터는 정상적이나 처리 불가
- 500 - 내부 서버 오류

로그인
-----

### /api/auth/facebook/token

입력된 Facebook access token으로 로그인을 실행합니다.

#### 입력

- access_token - Facebook의 access token입니다.

#### 출력

##### 로그인 성공

```js
{
  "code": 200,
  "token": "인증에 사용되는 API 토큰",
  "user": {
    "유저 정보": "..." // User 스키마를 참조하세요
  }
  "new": true // 새로 생성된 계정인지의 여부
}
```

##### 로그인 실패

```js
{
  "code": 401
}
```

### /api/auth/google/token

일단 구현하기 싫으므로 보류

### /api/auth/logout

토큰을 무효화하고 로그아웃 합니다.

#### 입력

- api_token - API 토큰입니다.

#### 출력

```js
{
  "code": 200
}
```

푸시 알림
--------

### /api/notification/token

Google Cloud Messaging의 토큰을 설정합니다.

#### 입력

- api_token - API 토큰입니다.
- token - GCM 토큰입니다.

#### 출력

```js
{
  "code": 200
}
```

### 메시지 읽음/삭제같은것도..

유저
----

### /api/user/self/info

자신의 유저 정보를 반환합니다.

#### 입력

- api_token - API 토큰입니다.

#### 출력

```js
{
  "code": 200,
  "user": {
    "유저 정보": "..." // User 스키마 참조
  }
}
```

### /api/user/self/delete

계정을 탈퇴하고 로그아웃합니다.

#### 입력

- api_token - API 토큰입니다.

#### 출력

```js
{
  "code": 200,
  "user": {
    "유저 정보": "..." // User 스키마 참조
  }
}
```

### /api/user/self/set

프로필을 설정합니다.

#### 입력

- api_token - API 토큰입니다.
- name - 이름
- phone - 전화번호
- description - 간단한 프로필

#### 출력

```js
{
  "code": 200,
  "user": {
    "유저 정보": "..." // User 스키마 참조
  }
}
```

### /api/user/info

유저의 정보를 반환합니다.

#### 입력

- id - 유저의 고유번호입니다.

#### 출력

```js
{
  "code": 200,
  "user": {
    "유저 정보": "..." // User 스키마 참조
  }
}
```

그룹
-----

### /api/group/self/list

자신이 속해있는 그룹의 목록을 나열합니다.

#### 입력

- api_token - API 토큰입니다.

#### 출력

```js
{
  "code": 200,
  "groups": [
    {
      "그룹 정보": "..." // Group 스키마 참조
    }
  ]
}
```

### /api/group/self/create

그룹을 만들고 자신을 거기에 추가합니다.

#### 입력

- api_token - API 토큰입니다.
- name - 그룹의 이름입니다.

#### 출력

##### 성공

```js
{
  "code": 200,
  "group": {
    "그룹 정보": "..." // Group 스키마 참조
  }
  "groups": [ // 유저가 속한 그룹의 정보
    {
      "그룹 정보": "..." // Group 스키마 참조
    }
  ]
}
```

##### 이미 해당 그룹이 존재하는 경우

```js
{
  "code": 422
}
```

### /api/group/self/join

자신을 그룹에 추가합니다.

#### 입력

- api_token - API 토큰입니다.
- id - 그룹의 ID입니다.

#### 출력

##### 성공

```js
{
  "code": 200,
  "group": {
    "그룹 정보": "..." // Group 스키마 참조
  }
  "groups": [ // 유저가 속한 그룹의 정보
    {
      "그룹 정보": "..." // Group 스키마 참조
    }
  ]
}
```

##### 그룹을 찾을 수 없는 경우

```js
{
  "code": 404
}
```

##### 이미 해당 그룹에 등록된 경우

```js
{
  "code": 422,
  "group": {
    "그룹 정보": "..." // Group 스키마 참조
  }
}
```

### /api/group/self/part

자신을 그룹에서 제거합니다.

#### 입력

- api_token - API 토큰입니다.
- id - 그룹의 ID입니다.

#### 출력

##### 성공

```js
{
  "code": 200,
  "group": {
    "그룹 정보": "..." // Group 스키마 참조
  }
  "groups": [ // 유저가 속한 그룹의 정보
    {
      "그룹 정보": "..." // Group 스키마 참조
    }
  ]
}
```

##### 그룹을 찾을 수 없는 경우

```js
{
  "code": 404
}
```

##### 이미 해당 그룹에 없는 경우

```js
{
  "code": 422,
  "group": {
    "그룹 정보": "..." // Group 스키마 참조
  }
}
```

### /api/group/search

그룹을 이름으로 검색합니다.

#### 입력

- name - 검색 키워드입니다.

#### 출력

```js
{
  "code": 200,
  "keyword": "검색 키워드",
  "groups": [
    {
      "그룹 정보": "..." // Group 스키마 참조
    }
  ]
}
```
