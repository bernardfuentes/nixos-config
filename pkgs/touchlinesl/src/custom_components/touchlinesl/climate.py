from homeassistant.components.climate import ClimateEntity
from homeassistant.components.climate.const import ClimateEntityFeature, HVACMode
from homeassistant.const import ATTR_TEMPERATURE, UnitOfTemperature
from pytouchlinesl import Module, TouchlineSL, Zone

from .const import (
    CONF_MODULE,
    CONF_PASSWORD,
    CONF_USERNAME,
    DOMAIN,
)

CONST_TEMP_PRESET_NAME = "Constant Temperature"


async def async_setup_entry(hass, entry, async_add_entities):
    """Set up the Touchline devices."""
    config = hass.data[DOMAIN][entry.entry_id]
    tsl = TouchlineSL(username=config[CONF_USERNAME], password=config[CONF_PASSWORD])
    module = await tsl.module(module_id=config[CONF_MODULE])

    if module:
        zones = await module.zones()
        async_add_entities(
            (TouchlineSLZone(id=z.id, name=z.name, module=module) for z in zones),
            True,
        )


class TouchlineSLZone(ClimateEntity):
    """Roth Touchline SL Zone."""

    _attr_temperature_unit = UnitOfTemperature.CELSIUS
    _attr_hvac_mode = HVACMode.HEAT
    _attr_hvac_modes = [HVACMode.HEAT]
    _attr_supported_features = (
        ClimateEntityFeature.TARGET_TEMPERATURE | ClimateEntityFeature.PRESET_MODE
    )

    def __init__(self, *, id, name, module):
        self.id: int = id
        self._name: str = name
        self._module: Module = module
        self._zone: Zone | None = None

        self._attr_unique_id = f"touchlinesl-{self._module.id}-zone-{self.id}"

        self._current_temperature: float | None = None
        self._target_temperature: float | None = None
        self._current_humidity: float | None = None
        self._current_operation_mode = HVACMode.HEAT
        self._preset_mode: str | None = None
        self._preset_modes: list[str] | None = None

    async def async_update(self) -> None:
        """Update zone attributes."""
        if z := await self._module.zone(self.id, refresh=True):
            self._zone = z
            self._name = z.name
            self._current_temperature = z.temperature
            self._target_temperature = z.target_temperature
            self._current_humidity = z.humidity

            schedules = await self._module.schedules()
            self._preset_modes = [s.name for s in schedules] + [CONST_TEMP_PRESET_NAME]
            self._preset_mode = z.mode

    async def async_set_temperature(self, **kwargs):
        """Set new target temperature."""
        if kwargs.get(ATTR_TEMPERATURE, None):
            self._target_temperature = kwargs.get(ATTR_TEMPERATURE)

        if self._zone and self._target_temperature:
            await self._zone.set_temperature(self._target_temperature)

    async def async_set_preset_mode(self, preset_mode: str) -> None:
        """Assign the zone to a particular global schedule."""
        if not self._zone:
            return

        schedules = await self._module.schedules()
        if not schedules:
            return

        if preset_mode == CONST_TEMP_PRESET_NAME and self._target_temperature:
            await self._zone.set_temperature(temperature=self._target_temperature)
            return

        if schedule := await self._module.schedule_by_name(preset_mode):
            await self._zone.set_schedule(schedule_id=schedule.id)

    @property
    def name(self) -> str | None:
        """Return the name of the climate device."""
        return self._name

    @property
    def current_temperature(self) -> float | None:
        """Return the current temperature."""
        return self._current_temperature

    @property
    def current_humidity(self) -> float | None:
        """Return the current humidity."""
        return self._current_humidity

    @property
    def target_temperature(self) -> float | None:
        """Return the target temperature for the zone."""
        return self._target_temperature

    @property
    def preset_mode(self) -> str | None:
        """Return the current preset mode."""
        return self._preset_mode

    @property
    def preset_modes(self) -> list[str] | None:
        """Return available preset modes."""
        return self._preset_modes
