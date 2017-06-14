all:
	rm -f target/mm3hack.nes target/digits_small.bin
	dd if=resources/digits.bin of=target/digits_small.bin bs=256 count=1
	cd src && ~/tmp/xkas-plus/xkas main.asm -ips -o ../ips/mm3hack.ips && cd -
	cp nes/mm3.nes target/mm3hack.nes
	~/tmp/ips.pl target/mm3hack.nes ips/mm3hack.ips

clean:
	rm -f target/*
