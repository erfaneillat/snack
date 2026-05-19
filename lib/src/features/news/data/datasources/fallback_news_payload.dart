const String fallbackNewsPayload = r'''
{
  "page": 1,
  "pageSize": 20,
  "totalCount": 160,
  "items": [
    {
      "id": 1567,
      "title": "معاون دانشجویی باشگاه پژوهشگران : طرح حامی فاصله میان دانشجو  و ساختار اداری را به حداقل رسانده",
      "summary": null,
      "image": "snhkhzgf.0qm.jpg",
      "publishDate": "2026-05-11T18:29:30.2633761",
      "link": "33FW56",
      "newsType": 0
    },
    {
      "id": 1526,
      "title": "معاون باشگاه پژوهشگران جوان و نخبگان دانشگاه آزاد اسلامی عنوان کرد «حامی»، گامی به سوی هوشمندسازی اداری، چابک سازی و حذف بروکراسی",
      "summary": null,
      "image": "m54fhgtw.wio.png",
      "publishDate": "2025-12-29T00:00:00",
      "link": "33XJ33",
      "newsType": 0
    },
    {
      "id": 1503,
      "title": "منتخبین رویدادهای نانو با حمایت باشگاه پژوهشگران به سوی صنعت هدایت می شوند",
      "summary": null,
      "image": "nvcznlgf.gnz.jpg",
      "publishDate": "2025-11-23T00:00:00",
      "link": "66WE85",
      "newsType": 0
    },
    {
      "id": 1499,
      "title": "بازدید مسئولین باشگاه پژوهشگران و نخبگان جوان دانشگاه آزاد اسلامی از نمایشگاه ایران نانو ۱۴۰۴",
      "summary": null,
      "image": "z4qfzj5q.foy.jpg",
      "publishDate": "2025-11-10T00:00:00",
      "link": "80CD92",
      "newsType": 0
    },
    {
      "id": 1491,
      "title": "مدیرکل هدایت و توانمندسازی باشگاه پژوهشگران منصوب شد",
      "summary": null,
      "image": "yh4qdmsg.nhn.jpg",
      "publishDate": "2025-10-21T00:00:00",
      "link": "34QK98",
      "newsType": 0
    },
    {
      "id": 1488,
      "title": "حل مشکلات ملی در گرو پیوند واقعی نخبگان با مسائل کشور",
      "summary": null,
      "image": "jdatabso.xbc.png",
      "publishDate": "2025-10-04T08:44:49.166376",
      "link": "72DS49",
      "newsType": 0
    },
    {
      "id": 1482,
      "title": "هفدهمین کنفرانس ملی بتن/بیست و سومین همایش روز بتن",
      "summary": null,
      "image": "kvdrd43h.ipz.jpg",
      "publishDate": "2025-09-24T00:00:00",
      "link": "18GV69",
      "newsType": 0
    },
    {
      "id": 1479,
      "title": "در گفت و گو با آنا مطرح شد: بهره گیری از توان نخبگان محور اصلی برنامه های دانشگاه آزاد اسلامی",
      "summary": null,
      "image": "colbqi2x.5y5.png",
      "publishDate": "2025-09-21T12:04:40.8577993",
      "link": "45PB76",
      "newsType": 0
    },
    {
      "id": 1480,
      "title": "در گفت و گو با آنا مطرح شد: شبکه نخبگان، مسیر توسعه کشور را هموار می کند",
      "summary": null,
      "image": "n2kx13f3.eek.png",
      "publishDate": "2025-09-21T00:00:00",
      "link": "85HO70",
      "newsType": 0
    },
    {
      "id": 1477,
      "title": "تاکنون 650 هزار درخواست دانشجویی بدون حضور در دانشگاه پاسخ داده شدند/2 هزار حامی پای کار دانشجویان دانشگاه آزاد",
      "summary": null,
      "image": "lt0zdn3x.sqs.png",
      "publishDate": "2025-09-20T00:00:00",
      "link": "68PJ28",
      "newsType": 0
    },
    {
      "id": 1472,
      "title": "مجوز تاسیس ۱۳ انجمن علمی دانشجویی دانشگاه آزاد اسلامی صادر شد",
      "summary": null,
      "image": "2dmfy5yy.i3i.png",
      "publishDate": "2025-08-19T13:38:44.4508369",
      "link": "23PW21",
      "newsType": 0
    },
    {
      "id": 1471,
      "title": "دامنه طرح های پژوهشی به انجمن های علمی رسید",
      "summary": null,
      "image": "huos30zl.ait.jpg",
      "publishDate": "2025-08-19T11:38:19.9134913",
      "link": "19KY21",
      "newsType": 0
    },
    {
      "id": 1463,
      "title": "مشق استادی در دانشگاه آزاد؛ روایت یک طرح تحول ساز",
      "summary": null,
      "image": "adeqvln1.wzu.png",
      "publishDate": "2025-06-30T00:00:00",
      "link": "94GI56",
      "newsType": 0
    },
    {
      "id": 1461,
      "title": "جلسه کمیسیون معاملات باشگاه پژوهشگران جوان برگزار شد",
      "summary": null,
      "image": "bp20g2nv.zgm.JPG",
      "publishDate": "2025-06-11T00:00:00",
      "link": "87QD21",
      "newsType": 0
    },
    {
      "id": 1462,
      "title": "با درخواست تأسیس 10 انجمن علمی دانشجویی موافقت شد",
      "summary": null,
      "image": "kpmyqhxv.ru1.png",
      "publishDate": "2025-06-11T00:00:00",
      "link": "28WR31",
      "newsType": 0
    },
    {
      "id": 1458,
      "title": "مراسم قدردانی از تیم اجرایی دانشجویی فعال در برگزاری هفتمین جشنواره فرهیختگان جوان برگزار شد",
      "summary": null,
      "image": "xbqrlhv5.qcw.jpg",
      "publishDate": "2025-06-02T00:00:00",
      "link": "23AU76",
      "newsType": 0
    },
    {
      "id": 1455,
      "title": "در مراسم گرامیداشت چهل و سومین سالگرد تاسیس دانشگاه آزاد اسلامی مطرح شد/اجرای نظام تحولی اداری با محوریت «حامی» در پاسخ گویی به دانشجویان دانشگاه آزاد اسلامی",
      "summary": null,
      "image": "pqywm1vh.bg2.png",
      "publishDate": "2025-06-01T00:00:00",
      "link": "93BR71",
      "newsType": 0
    },
    {
      "id": 1456,
      "title": "از سوی رییس باشگاه پژوهشگران جوان و نخبگان: جزییات فراخوان پنجم طرح دستیاری آموزشی اعلام شد",
      "summary": null,
      "image": "favk0adb.ww1.jpg",
      "publishDate": "2025-06-01T00:00:00",
      "link": "63OO26",
      "newsType": 0
    },
    {
      "id": 1457,
      "title": "توسط مسئولان ستاد مرکزی باشگاه پژوهشگران جوان و نخبگان انجام شد/ بررسی مشکلات سامانه طرح حامی در دانشگاه آزاد اسلامی واحد علوم و تحقیقات",
      "summary": null,
      "image": "a2bihkii.yr1.jpg",
      "publishDate": "2025-06-01T00:00:00",
      "link": "62GV30",
      "newsType": 0
    },
    {
      "id": 1448,
      "title": "برگزاری مراسم تقدیر از همکار بازنشسته باشگاه پژوهشگران جوان و نخبگان",
      "summary": null,
      "image": "5cxsy50k.1t0.jpg",
      "publishDate": "2025-05-22T00:00:00",
      "link": "48QN49",
      "newsType": 0
    }
  ]
}
''';
