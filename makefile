PROG_NAME=executable
BUILD_DIR=build
UPDATE_OBJ=mkdir -p $(BUILD_DIR) && nasm -g -f elf64


main.o: main.asm dict.o lib.o words.o
	$(UPDATE_OBJ) $< -o ./$(BUILD_DIR)/$@

dict.o: dict.asm lib.o
	$(UPDATE_OBJ) $< -o ./$(BUILD_DIR)/$@

lib.o: lib.asm
	$(UPDATE_OBJ) $< -o ./$(BUILD_DIR)/$@

words.o: words.inc
	$(UPDATE_OBJ) $< -o ./$(BUILD_DIR)/$@


.PHONY: clean build

clean:
	rm -rf $(BUILD_DIR)

build: main.o dict.o lib.o words.o
	cd $(BUILD_DIR) && $(LD) $^ -o $(PROG_NAME) && cd ..

run:
	./$(BUILD_DIR)/$(PROG_NAME)

debug:
	gdb ./$(BUILD_DIR)/$(PROG_NAME)
