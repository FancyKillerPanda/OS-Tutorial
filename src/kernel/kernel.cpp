//  ===== Date Created: 20 July, 2021 ===== 

extern "C" void kmain()
{
	u8* address = (u8*) 0xb8000;
	const char* string = "Hello, world!";
	u16 stringSize = 13;

	for (u16 i = 0; i < stringSize; i++)
	{
		*address = (u8) string[i];
		address += 1;
		*address = (u8) 0x9f;
		address += 1;
	}

	while (true);
}
