//  ===== Date Created: 20 July, 2021 ===== 

extern "C" void kmain()
{
	unsigned char* address = (unsigned char*) 0xb8000;
	const char* string = "Hello, world!";
	unsigned short stringSize = 13;

	for (unsigned short i = 0; i < stringSize; i++)
	{
		*address = (unsigned char) string[i];
		address += 1;
		*address = (unsigned char) 0x9f;
		address += 1;
	}

	while (true);
}
