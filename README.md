# Iran University Portal

A Flutter application for a Persian RTL university website.

The app currently includes:

- A competitions and events page for contests, webinars, filters, featured
  events, and active registrations.
- A news feed page for Islamic Azad University Young Researchers and Elite
  Club. It fetches:

```text
https://bpj.iau.ir/api/v1/news/list?page=1&pageSize=20&type=0
```

If the API is blocked or unavailable during local development, the app displays
the documented sample response as fallback data.
