import asyncio
import json
import os

from prettytable import PrettyTable

from .touchline_api import Account, Module


async def test(account):
    auth = await account.login()

    module = Module(
        user_id=auth.user_id,
        token=auth.token,
        module_id="a7d227f31fc45c64c0c8eb83dc8d60ac",
    )
    await module.update()

    with open("dump.json", "w+") as f:
        f.write(json.dumps(await module._module_info(), indent=2))

    table = PrettyTable()
    table.field_names = [
        "ID",
        "Name",
        "Mode",
        "Schedule",
        "Target Temp",
        "Current Temp",
    ]
    for zone in module.zones():
        table.add_row(
            [
                zone.id,
                zone.name,
                zone.mode,
                zone.schedule,
                zone.target_temperature,
                zone.temperature,
            ]
        )

    print(table)

    laura_office = module.zone_by_id(2448)
    # result = await laura_office.set_temperature(17.0)
    # result = await laura_office.set_schedule(0)

    kitchen = module.zone_by_id(2411)
    # result = await kitchen.set_schedule_in_zones()
    # print(result)

    for s in module.schedules():
        print(s.id, s.name)


if __name__ == "__main__":
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

    try:
        account = Account(
            username=os.getenv("TOUCHLINESL_LOGIN", ""),
            password=os.getenv("TOUCHLINESL_PASSWORD", ""),
        )
        asyncio.run(test(account))
    except KeyboardInterrupt:
        pass
