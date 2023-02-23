import os

from google.cloud import secretmanager
import google_crc32c


def get_secret_value(name: str):
    client = secretmanager.SecretManagerServiceClient()
    name = client.secret_version_path(os.getenv("PROJECT_ID"), name, "latest")
    response = client.access_secret_version(request={"name": name})

    crc32c = google_crc32c.Checksum()
    crc32c.update(response.payload.data)

    if response.payload.data_crc32c != int(crc32c.hexdigest(), 16):
        print("Data corruption detected.")
        return

    payload = response.payload.data.decode("UTF-8")

    return payload


name = get_secret_value("name")
print(f"Hello {name}!")
