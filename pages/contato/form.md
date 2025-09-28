---
title: Contato
published: true
form:
    name: 'Entre em contato'
    fields:
        -
            name: name
            label: Nome
            placeholder: 'Informe seu nome'
            autofocus: 'on'
            autocomplete: 'on'
            type: text
            validate:
                required: true
        -
            name: email
            label: Email
            placeholder: 'Informe seu emelho'
            type: text
            validate:
                rule: email
                required: true
        -
            name: message
            label: Mensagem
            size: long
            placeholder: 'Me conte...'
            type: textarea
            validate:
                required: true
    buttons:
        -
            type: submit
            value: Submit
            classes: 'gdlr-button with-border excerpt-read-more'
    process:
        -
            email:
                from: '{{ config.plugins.email.from }}'
                to:
                    - '{{ config.plugins.email.from }}'
                    - '{{ form.value.email }}'
                subject: '[Feedback] {{ form.value.name|e }}'
                body: '{% include ''forms/data.html.twig'' %}'
        -
            save:
                fileprefix: feedback-
                dateformat: Ymd-His-u
                extension: txt
                body: '{% include ''forms/data.txt.twig'' %}'
        -
            message: 'Obrigado pelo seu feedback!'
        -
            display: thankyou
taxonomy:
    category:
        - contato
    tag:
        - email
        - contato
---

