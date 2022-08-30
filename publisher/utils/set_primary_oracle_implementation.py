import asyncio
import os

from empiric.admin.client import EmpiricAdminClient


async def main():
    admin_private_key = int(os.environ.get("ADMIN_PRIVATE_KEY"), 0)
    admin_client = EmpiricAdminClient(
        admin_private_key,
    )
    await admin_client.set_primary_oracle_implementation_address(
        0x037087CD9A886482EFF2192486785204A5CFE0A78496FFB0E0F2BF71F02F65E1
    )


if __name__ == "__main__":
    asyncio.run(main())
