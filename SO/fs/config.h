#ifndef CONFIG_H
#define CONFIG_H

/* FS root inode number */
#define ROOT_DIR_INUM (0)

#define BLOCK_SIZE (1024)
#define DATA_BLOCKS (1024)
#define MAX_FILE_SIZE (BLOCK_SIZE * (INODE_BLOCKS + (BLOCK_SIZE / sizeof(int))))
#define BLOCK_OF_BLOCKS 10

#define INODE_TABLE_SIZE (50)
#define MAX_OPEN_FILES (20)
#define MAX_FILE_NAME (40)

#define DELAY (5000)

#endif // CONFIG_H
