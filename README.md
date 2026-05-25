# Iran University Portal

A Flutter application for a Persian RTL university website.

The app currently includes:

- A competitions and events page for contests, webinars, filters, featured
  events, and active registrations.
- A news feed page for Islamic Azad University Young Researchers and Elite
  Club.
- A weblog page for long-form updates, reports, and editorial posts.

The app fetches remote content from the configured API endpoints, including:

```text
https://bpj.iau.ir/api/v1/news/list?page=1&pageSize=20&type=0
https://bpj.iau.ir/api/v1/events/list?page=1&pageSize=20&type=0
https://bpj.iau.ir/api/v1/weblog/list?page=1&pageSize=20
```

If the API is blocked or unavailable, the related page shows the connection
error state instead of displaying sample data.
