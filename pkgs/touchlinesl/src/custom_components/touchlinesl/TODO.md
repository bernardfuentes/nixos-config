- Exception handling for logins/api interactions
- Pass `hass` session into module/account client? :

```python
from homeassistant.helpers.aiohttp_client import (
    async_create_clientsession,
    async_get_clientsession,
)

# ...
session = async_get_clientsession(hass)
```

- [x] Humidity support
- [x] Set temp support
- [ ] Schedules/presets support
- [ ] Type annotations
- [ ] Unit tests

# Docs

- https://developers.home-assistant.io/docs/core/entity/climate/#supported-features
- https://github.com/home-assistant/core/blob/dev/homeassistant/components/climate/__init__.py
- https://api-documentation.roth-touchlinesl.com/

# Example

- https://github.com/home-assistant/core/blob/dev/homeassistant/components/touchline/climate.py
