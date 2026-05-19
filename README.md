# Iran University Portal

A Flutter application for a Persian RTL university website.

The first implemented page is the news feed for Islamic Azad University Young
Researchers and Elite Club. It fetches:

```text
https://bpj.iau.ir/api/v1/news/list?page=1&pageSize=20&type=0
```

If the API is blocked or unavailable during local development, the app displays
the documented sample response as fallback data.
