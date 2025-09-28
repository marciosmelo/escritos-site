---
title: Histórias
process:
    markdown: true
    twig: true
admin:
    children_display_order: default
content:
    items: '@self.children'
    order:
        by: folder
        dir: asc
    pagination: true
---

