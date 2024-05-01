from dataclasses import dataclass

import aiohttp

from .const import API_URL

THERMOSTAT_MODES = ["constantTemp", "globalSchedule", "localSchedule"]


@dataclass
class _LoginResponse:
    authenticated: bool
    user_id: int
    access_google_home: bool
    token: str


@dataclass
class Schedule:
    id: str
    name: str
    index: str


class Account:
    def __init__(self, *, username, password):
        self.username = username
        self.password = password
        self.auth = None

    async def login(self):
        async with aiohttp.ClientSession() as session:
            data = {"username": self.username, "password": self.password}
            r = await session.post(f"{API_URL}/authentication", json=data)

        if r.status == 200:
            response_json = await r.json()
            self.auth = _LoginResponse(**response_json)
            return _LoginResponse(**response_json)
        else:
            return None

    async def authenticated(self) -> bool:
        if self.auth is None:
            return False

        async with aiohttp.ClientSession() as session:
            r = await session.get(
                f"{API_URL}/authentication",
                headers={"authorization": "Bearer " + self.auth.token},
            )
            response_json = await r.json()
            return response_json.get("authenticated", False)

    async def modules(self):
        if self.auth is None:
            raise Exception("not authenticated")

        async with aiohttp.ClientSession() as session:
            r = await session.get(
                f"{API_URL}/users/{self.auth.user_id}/modules",
                headers={"authorization": "Bearer " + self.auth.token},
            )

        return await r.json()


class Zone:
    def __init__(self, module, zone_data):
        self._module = module
        self._raw_data = zone_data
        self.id = self._raw_data["zone"]["id"]
        self.name = self._raw_data["description"]["name"]

    @property
    def temperature(self):
        return float(int(self._raw_data["zone"]["currentTemperature"]) / 10)

    @property
    def target_temperature(self):
        return float(int(self._raw_data["zone"]["setTemperature"]) / 10)

    @property
    def humidity(self):
        return float(int(self._raw_data["zone"]["humidity"]))

    @property
    def mode(self):
        return self._raw_data["mode"]["mode"]

    @property
    def schedule(self):
        if self.mode == "constantTemp":
            return None
        else:
            return self._module.schedule_by_idx(self._raw_data["mode"]["scheduleIndex"])

    async def set_temperature(self, target_temperature: float):
        async with aiohttp.ClientSession() as session:
            r = await session.post(
                f"{API_URL}/users/{self._module.user_id}/modules/{self._module.module_id}/zones",
                headers={"authorization": "Bearer " + self._module.token},
                json={
                    "mode": {
                        "id": self._raw_data["mode"]["id"],
                        "parentId": self.id,
                        "mode": "constantTemp",
                        "constTempTime": 0,
                        "setTemperature": int(target_temperature * 10),
                        "scheduleIndex": 0,
                    }
                },
            )
            return await r.json()

    async def set_schedule(self, schedule_idx: int):
        async with aiohttp.ClientSession() as session:
            r = await session.post(
                f"{API_URL}/users/{self._module.user_id}/modules/{self._module.module_id}/zones",
                headers={"authorization": "Bearer " + self._module.token},
                json={
                    "mode": {
                        "id": self._raw_data["mode"]["id"],
                        "parentId": self.id,
                        "mode": "globalSchedule",
                        "constTempTime": 60,
                        "setTemperature": int(self.target_temperature * 10),
                        "scheduleIndex": schedule_idx,
                    }
                },
            )
            return await r.json()

    async def set_schedule_in_zones(self):
        async with aiohttp.ClientSession() as session:
            r = await session.post(
                f"{API_URL}/users/{self._module.user_id}/modules/{self._module.module_id}/zones/{self.id}/global_schedule",
                headers={"authorization": "Bearer " + self._module.token},
                json={
                    "scheduleName": "Living Spaces",
                    "setInZones": [{"zoneId": 2411, "modeId": 2413}],
                    "schedule": {
                        "id": 2948,
                        # "parentId": 2333,
                        "index": 0,
                        "p0Days": ["1", "1", "1", "1", "1", "1", "1"],
                        "p0SetbackTemp": 180,
                        "p0Intervals": [
                            {"start": 300, "stop": 540, "temp": 200},
                            # {"start": 6100, "stop": 6100, "temp": 200},
                            # {"start": 6100, "stop": 6100, "temp": 200},
                        ],
                        "p1Days": ["0", "0", "0", "0", "0", "0", "0"],
                        "p1SetbackTemp": 175,
                        "p1Intervals": [
                            # {"start": 6100, "stop": 6100, "temp": 200},
                            # {"start": 6100, "stop": 6100, "temp": 200},
                            # {"start": 6100, "stop": 6100, "temp": 200},
                        ],
                    },
                },
            )
            return await r.json()


class Module:
    def __init__(self, *, user_id, token, module_id):
        self.token: str = token
        self.user_id = user_id
        self.module_id = module_id
        self._raw_data: dict = {}
        self._zones: list[Zone] = []

    async def update(self):
        self._raw_data = await self._module_info()

        self._zones = [
            Zone(self, z)
            for z in self._raw_data["zones"]["elements"]
            if z["zone"]["zoneState"] != "zoneOff"
        ]

        self._schedules = [
            Schedule(id=s["id"], name=s["name"], index=s["index"])
            for s in self._raw_data["zones"]["globalSchedules"]["elements"]
        ]

    async def _module_info(self):
        async with aiohttp.ClientSession() as session:
            r = await session.get(
                f"{API_URL}/users/{self.user_id}/modules/{self.module_id}",
                headers={"authorization": "Bearer " + self.token},
            )
            return await r.json()

    def zones(self):
        return self._zones

    def zone_by_id(self, zone_id):
        return next((z for z in self._zones if z.id == zone_id))

    def schedules(self):
        return self._schedules

    def schedule_by_id(self, schedule_id):
        return next((s for s in self._schedules if s.id == schedule_id))

    def schedule_by_idx(self, schedule_idx):
        return next((s for s in self._schedules if s.index == schedule_idx))
