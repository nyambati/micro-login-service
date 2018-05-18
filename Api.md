## **Get users **

- **URL**

/users

- **Method:**

`GET`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:** `[ [ { "id": "-LDCmSjFB96SHiylH0Uk", "email": "thalkifly.hassan@andela.com", "roles": [ { "id": 2, "name": "admin", "created_at": "2018-05-23T14:49:53.223Z", "updated_at": "2018-05-23T14:49:53.223Z", "domain": "https://andela.com" } ] } ] ]`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

---

- **Sample Call:**
  ```
  curl localhost:3000/users --header "Authorization: my super long token"
  ```

---

- **Notes:**

<em>Only available to admin users</em>

## **Post Users**

- **URL**

/users

- **Method:**

`Post`

- **Success Response:**

* **Code:** <code>201 Created</code> <br />
  **Content:** `{ "skiped": [], "created": [ sir3n.sn@gmail.com ], info: [] }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

---

- **Sample Call:**
  ```
  curl localhost:3000/users --header "Authorization: token" -H "Content-Type: application/json" --request POST --data '{
  "users": [ {"email": "sir3n.sn@gmail.com", "firstname": "dhul", "lastname": "kali"}],
  "role":"vof-guest"
  }'
  ```

---

- **Notes:**

<em>Only available to admin users</em>

## **Login User**

- **URL**

/users/login

- **Method:**

`Post`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:**
  ```
  {
    "auth_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJleHAiOjE1MjY2NzcwMzYsImlzcyI6ImFuZGVsYSIsImF1ZCI6ImNsaWVudCIsIlVzZXJJbmZvIjp7InVzZXJfaWQiOjMsImVtYWlsIjoidGhhbGtpZmx5Lmhhc3NhbkBhbmRlbGEuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiZG9tYWluIjpbImh0dHBzOi8vd3d3LmFuZGVsYS5jb20iXX19.yGr2lt5Gn5hN-YoFAc8nLqkgVElX3apusoV1mkkbot-XLkFP_gykB0BjqDuFm61U03GYaDeRDjE2hUgPCeG6nMW-_q1IxEwi_j0gNRyKu2oKOLvIx-EBroU-2iEl_t7mAUyurC55X3rSBBLPWxT3pnMYJPHqf9Y5Gf1pflbXiKuLqmNvczfYkyCan-torl4CWeCQfBPgsthNFfMi6bNZ1tbf3OjrO9PqMPzRfSnwq48LcXFoMzbFSO06TaIhQbOla-gL82U7VcN5ouKJNHIkRKbfaCEMv433JftpgOJ7ySIHoPI5ohk-0ZW8orobYoWphgoX7ibPQjmgyL7VJ_UrA"
  }
  ```

---

- **Error Response:**

* **Code:** <code>401 Invalid Credentials</code> <br />
  **Content:** `{ "error": "Invalid Credentials" }`

---

- **Sample Call:**

```
curl localhost:3000/users/login -H "Content-Type: application/json" --request POST --data '{
"email": "sir3n.sn@gmail.com",
"role":"my-fake-password"
}'
```

---

- **Notes:**

<em>Available to all users</em>

## **Generate Access token **

- **URL**

/generate_access_token

- **Method:**

`GET`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:** `{ "message": "Please check your email for an access token" }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

---

- **Sample Call:**
  ```
  curl localhost:3000/users/generate_access_token --header "Authorization: my super long token"
  ```

---

- **Notes:**

<em>Only available to admin users</em>

## **Put Users**

- **URL**

/users/:id

- **Method:**

`PUT`

- **Required**

`id=[Integer]`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:** `{ "id": 66, "email": "sir3n@gmail.com" }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

---

- **Sample Call:**

```
curl localhost:3000/users --header "Authorization: token" -H "Content-Type: application/json" --request PUT --data '{
"email":"sir3n@gmail.com"
}'
```

---

- **Notes:**
  <em>Returns null when invalid data is provided</em>

<em>Only available to admin users</em>

## **Delete User**

- **URL**

/users/:id

- **Method:**

`DELETE`

- **Required**

`id=[Integer]`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:** `{ "message": "Success" }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

- **Code:** <code>404 Not found</code>

**Content:** `{ "error": "Couldn't find User with 'id'=77" }`

---

- **Sample Call:**

```
curl localhost:3000/users/66 --header "Authorization: token" -H "Content-Type: application/json" --request DELETE'
```

---

- **Notes:**

<em>Only available to admin users</em>

## **Get roles **

- **URL**

/roles

- **Method:**

`GET`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:** `[{ "id": 4, "name": "admin", "domain": "https://www.andela.com" }]`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

---

- **Sample Call:**

```
curl localhost:3000/roles --header "Authorization: my super long token"
```

---

- **Notes:**

<em>Only available to admin users</em>

## **Post roles**

- **URL**

/roles

- **Method:**

`Post`

- **Success Response:**

* **Code:** <code>201 Created</code> <br />
  **Content:** `{ "id": 26, "name": "test", "domain": "https://www.google.com" }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`
* **Code:** <code>422 Unproccessable entitiy</code> <br />
  **Content:**

```
{ "error": "param is missing or the value is empty: domain" }
{ "error": "param is missing or the value is empty: name" }
```

**Code:** <code>400 bad request</code>

**Content:** `{ "error": "Please input a full valid domain url" }`

---

- **Sample Call:**

```
curl localhost:3000/roles --header "Authorization: token" -H "Content-Type: application/json" --request POST --data '{
"name": "test",
"domain":"https://www.google.com"
}'
```

---

- **Notes:**

<em>Only available to admin users</em>

## **PUT roles**

- **URL**

/roles/:id

- **Method:**

`PUT`

- **Success Response:**

* **Code:** <code>201 Created</code> <br />
  **Content:** `{ "id": 26, "name": "test", "domain": "https://www.google.com" }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`
* **Code:** <code>422 Unproccessable entitiy</code> <br />
  **Content:**

```
{ "error": "param is missing or the value is empty: domain" }
```

**Code:** <code>400 bad request</code>

**Content:** `{ "error": "Please input a full valid domain url" }`

---

- **Sample Call:**

```
curl localhost:3000/roles/26 --header "Authorization: token" -H "Content-Type: application/json" --request PUT --data '{
"name": "EDITED NAME",
"domain":"https://www.google.com"
}'
```

---

- **Notes:**

<em>Only available to admin users</em>

## **Delete Role**

- **URL**

/roles/:id

- **Method:**

`DELETE`

- **Required**

  `id=[Integer]`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:** `{ "message": "Success" }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

- **Code:** <code>404 Not found</code>

  **Content:** `{ "error": "Couldn't find Role with 'id'=77" }`

---

- **Sample Call:**

```
curl localhost:3000/roles/66 --header "Authorization: token" -H "Content-Type: application/json" --request DELETE'
```

---

- **Notes:**

<em>Only available to admin users</em>

## **POST /password/forgot**

- **URL**

/password/forgot

- **Method:**

`POST`

- **Success Response:**

* **Code:** <code>200 OK</code> <br />
  **Content:** `{ "linkSent": "A link has been sent. Please check your email" }`

---

- **Error Response:**

* **Code:** <code>401 UNAUTHORIZED</code> <br />
  **Content:** `{ error : "Unauthorized" }`

**Code:** <code>404 not found</code> <br />
**Content:** `{ "error": "Sorry record not found" }`

---

- **Sample Call:**

```
curl localhost:3000/password/forgot --header "Authorization: token" -H "Content-Type: application/json" --request PUT --data '{
"email":"sir3n@gmail.com"
}'
```

---

- **Notes:**

<em>Available to all users</em>
