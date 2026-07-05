BR2_EXT = $(CURDIR)/br2-external-msaf
BUILDROOT_DIR  = $(CURDIR)/buildroot-2024.02

# Supported target boards
BOARDS = qoriq my_laptop

# Default board
DEFAULT_BOARD = my_laptop

.PHONY: all clean $(BOARDS)

# Check if the user has provided any known board name in the goals
CHOSEN_BOARD := $(filter $(BOARDS),$(MAKECMDGOALS))
BOARD_DEFCONFIG := $(filter %_defconfig, $(MAKECMDGOALS))

# If no board name is found, fall back to the default board
ifeq ($(CHOSEN_BOARD),)
    TARGET_BOARD = $(DEFAULT_BOARD)
    # all provided arguments are targets (goals)
    BR2_GOALS = $(MAKECMDGOALS)
else
    TARGET_BOARD = $(CHOSEN_BOARD)
    # If board is certain, filter targets (goals)
    BR2_GOALS = $(filter-out $(BOARDS),$(MAKECMDGOALS))
endif

# Default target (goal) is all
ifeq ($(BR2_GOALS),)
    BR2_GOALS = all
endif

# Default target
all:
	@$(MAKE) $(DEFAULT_BOARD)
	
	
#@$(MAKE) --no-print-directory $(DEFAULT_BOARD)

# Rules for certain boards
$(BOARDS):
	@echo "[Board is: $(TARGET_BOARD)] Initialization..."
	$(MAKE) -C $(BUILDROOT_DIR) BR2_EXTERNAL=$(BR2_EXT) \
		O=$(CURDIR)/common-output/$(TARGET_BOARD) $(BOARD_DEFCONFIG)
	@echo "[Board: $(TARGET_BOARD)] Run targets: [ $(BR2_GOALS) ]..."
	$(MAKE) -C $(BUILDROOT_DIR) BR2_EXTERNAL=$(BR2_EXT) \
		O=$(CURDIR)/common-output/$(TARGET_BOARD) $(BR2_GOALS)


	#@if echo "$(BR2_GOALS)" | grep -qE "config" ; then \
		echo "=== [Board: $(TARGET_BOARD)] save defconfig ==="; \
		$(MAKE) -C $(BUILDROOT_DIR) savedefconfig; \
	fi

# Заглушка, чтобы главный Make не ругался на специфичные цели Buildroot
%:
	@:

# Очистка внешних директорий вывода
clean:
	rm -rf $(CURDIR)/build-output/
