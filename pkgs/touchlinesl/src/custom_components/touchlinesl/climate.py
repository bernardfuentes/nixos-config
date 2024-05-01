from homeassistant.components.climate import (
    ClimateEntity,
    ClimateEntityFeature,  # type: ignore
    HVACMode,  # type: ignore
)
from homeassistant.const import ATTR_TEMPERATURE, UnitOfTemperature

from .const import CONF_AUTH_TOKEN, CONF_MODULE, CONF_USER_ID, DOMAIN
from .touchline_api import Module


async def async_setup_entry(hass, entry, async_add_entities):
    """Set up the Touchline devices."""

    config = hass.data[DOMAIN][entry.entry_id]

    module = Module(
        user_id=config[CONF_USER_ID],
        token=config[CONF_AUTH_TOKEN],
        module_id=config[CONF_MODULE],
    )
    await module.update()

    async_add_entities(
        (TouchlineSLZone(id=z.id, name=z.name, module=module) for z in module.zones()),
        True,
    )


class TouchlineSLZone(ClimateEntity):
    """Roth TouchlineSL Zone."""

    _attr_temperature_unit = UnitOfTemperature.CELSIUS
    _attr_hvac_mode = HVACMode.HEAT
    _attr_hvac_modes = [HVACMode.HEAT]
    _attr_supported_features = (
        ClimateEntityFeature.TARGET_TEMPERATURE | ClimateEntityFeature.PRESET_MODE
    )

    def __init__(self, *, id, name, module):
        self.id = id
        self._name = name
        self._module = module
        self._zone = None

        self._attr_unique_id = f"touchlinesl-{self._module.module_id}-zone-{self.id}"

        self._current_temperature = None
        self._target_temperature = None
        self._current_humidity = None
        self._current_operation_mode = None
        self._preset_mode = None

    async def async_update(self) -> None:
        """Update thermostat attributes."""
        await self._module.update()
        self._zone = self._module.zone_by_id(self.id)

        self._name = self._zone.name
        self._current_temperature = self._zone.temperature
        self._target_temperature = self._zone.target_temperature
        self._current_humidity = self._zone.humidity
        self._preset_mode = None

    async def async_set_temperature(self, **kwargs):
        """Set new target temperature."""
        if kwargs.get(ATTR_TEMPERATURE) is not None:
            self._target_temperature = kwargs.get(ATTR_TEMPERATURE)
        await self._zone.set_temperature(self._target_temperature)

    @property
    def name(self):
        """Return the name of the climate device."""
        return self._name

    @property
    def current_temperature(self):
        """Return the current temperature."""
        return self._current_temperature

    @property
    def current_humidity(self):
        """Return the current humidity."""
        return self._current_humidity

    @property
    def target_temperature(self):
        """Return the target temperature for the zone."""
        return self._target_temperature

    @property
    def preset_mode(self):
        """Return the current preset mode."""
        return self._preset_mode

    @property
    def preset_modes(self):
        """Return available preset modes."""
        return []
