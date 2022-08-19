#include "operations.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

int tfs_init() {
    state_init();

    /* create root inode */
    int root = inode_create(T_DIRECTORY);
    if (root != ROOT_DIR_INUM) {
        return -1;
    }

    return 0;
}

int tfs_destroy() {
    state_destroy();
    return 0;
}

static bool valid_pathname(char const *name) {
    return name != NULL && strlen(name) > 1 && name[0] == '/';
}

int tfs_lookup(char const *name) {
    if (!valid_pathname(name)) {
        return -1;
    }

    // skip the initial '/' character
    name++;

    return find_in_dir(ROOT_DIR_INUM, name);
}
// TODO: Lock para obter filehandles diferentes.

int tfs_open(char const *name, int flags) {
    int inum;
    size_t offset;

    /* Checks if the path name is valid */
    if (!valid_pathname(name)) {
        return -1;
    }

    inum = tfs_lookup(name);
    if (inum >= 0) {
        /* The file already exists */
        inode_t *inode = inode_get(inum);
        if (inode == NULL) {
            return -1;
        }

        /* Trucate (if requested) */
        if (flags & TFS_O_TRUNC) {
            pthread_rwlock_rdlock(&inode->lock);
            if (inode->i_size > 0) {
                void *block_of_blocks =
                    data_block_get(inode->data_blocks_addr[BLOCK_OF_BLOCKS]);
                    
                for (int i = 0; i < INODE_BLOCKS + (BLOCK_SIZE / sizeof(int)); i++) {
                    if (i < INODE_BLOCKS) {
                        if (data_block_free(inode->data_blocks_addr[i]) == -1) {
                            pthread_rwlock_unlock(&inode->lock); 
                            return -1;
                        }
                    
                    } else {
                        if (block_of_blocks != NULL) {
                            int block_to_free = 
                                *((int *)block_of_blocks + ((int)sizeof(int) * i));

                            if (data_block_free(block_to_free) == -1) {
                                pthread_rwlock_unlock(&inode->lock);
                                return -1;
                            }
                        }
                    }
                }
                
                inode->i_size = 0;
            }
            pthread_rwlock_unlock(&inode->lock);
        }
        /* Determine initial offset */
        if (flags & TFS_O_APPEND) {
            pthread_rwlock_wrlock(&inode->lock);
            offset = inode->i_size;
            pthread_rwlock_unlock(&inode->lock);
        } else {
            offset = 0;
        }
    } else if (flags & TFS_O_CREAT) {
        /* The file doesn't exist; the flags specify that it should be created*/
        /* Create inode */
        inum = inode_create(T_FILE);
        if (inum == -1) {
            return -1;
        }
        /* Add entry in the root directory */
        if (add_dir_entry(ROOT_DIR_INUM, inum, name + 1) == -1) {
            inode_delete(inum);
            return -1;
        }
        offset = 0;
    } else {
        return -1;
    }

    /* Finally, add entry to the open file table and
     * return the corresponding handle */
    return add_to_open_file_table(inum, offset);

    /* Note: for simplification, if file was created with TFS_O_CREAT and there
     * is an error adding an entry to the open file table, the file is not
     * opened but it remains created */
}

int tfs_close(int fhandle) { return remove_from_open_file_table(fhandle); }

ssize_t tfs_write(int fhandle, void const *buffer, size_t to_write) {
    open_file_entry_t *file = get_open_file_entry(fhandle);
    if (file == NULL) {
        return -1;
    }

    /* From the open file table entry, we get the inode */
    inode_t *inode = inode_get(file->of_inumber);
    if (inode == NULL) {
        return -1;
    }

    /* Determine how many bytes to write */
    if (to_write + file->of_offset > MAX_FILE_SIZE) {
        to_write = MAX_FILE_SIZE - file->of_offset;
    }

    if (to_write > 0) {

        size_t to_write_aux = to_write;

        void *data_block;

        void *block_of_blocks =
            data_block_get(inode->data_blocks_addr[BLOCK_OF_BLOCKS]);

        pthread_rwlock_wrlock(&inode->lock);
        while (to_write_aux > 0) {

            size_t current_block = file->of_offset / BLOCK_SIZE;

            size_t block_offset = file->of_offset % BLOCK_SIZE;

            size_t buffer_offset = to_write - to_write_aux;

            size_t buffer_size =
                to_write_aux > BLOCK_SIZE ? BLOCK_SIZE : to_write_aux;

            // Primeiro buscar o endereco
            if (current_block < INODE_BLOCKS) {
                int *current_block_num =
                    &inode->data_blocks_addr[current_block];

                data_block = data_block_get(*current_block_num);

                if (data_block == NULL || *current_block_num == -1) {
                    *current_block_num = data_block_alloc();

                    if (*current_block_num == -1) {
                        return (ssize_t)(to_write - to_write_aux);
                    }

                    data_block = data_block_get(*current_block_num);
                }

            } else {
                int *current_block_num =
                    &inode->data_blocks_addr[BLOCK_OF_BLOCKS];

                if (block_of_blocks == NULL || *current_block_num == -1) {
                    *current_block_num = data_block_alloc();

                    if (*current_block_num == -1) {
                        return (ssize_t)(to_write - to_write_aux);
                    }

                    block_of_blocks = data_block_get(*current_block_num);
                }

                int index_block_offset = (int)current_block - INODE_BLOCKS;

                data_block = data_block_get(*(int *)block_of_blocks +
                                            index_block_offset);

                if (data_block == NULL ||
                    *((int *)block_of_blocks + index_block_offset) == 0) {
                    *((int *)block_of_blocks + index_block_offset) =
                        data_block_alloc();

                    if (*((int *)block_of_blocks + index_block_offset) == -1) {
                        return (ssize_t)(to_write - to_write_aux);
                    }
                    data_block = data_block_get(*(int *)block_of_blocks +
                                                index_block_offset);
                }
            }
            // Depois escrever

            memcpy(data_block + block_offset, buffer + buffer_offset,
                   buffer_size);

            // Incrementar variaveis necessarias

            to_write_aux -= buffer_size;

            file->of_offset += buffer_size;

            inode->i_size += buffer_size;
        }
    }
    pthread_rwlock_unlock(&inode->lock);

    return (ssize_t)to_write;
}

ssize_t tfs_read(int fhandle, void *buffer, size_t len) {
    open_file_entry_t *file = get_open_file_entry(fhandle);
    if (file == NULL) {
        return -1;
    }

    /* From the open file table entry, we get the inode */
    inode_t *inode = inode_get(file->of_inumber);
    if (inode == NULL) {
        return -1;
    }

    /* Determine how many bytes to read */
    size_t to_read = inode->i_size - file->of_offset;
    if (to_read > len) {
        to_read = len;
    }

    if (file->of_offset + to_read > inode->i_size) {
        return -1;
    }

    ssize_t written = 0;

    if (to_read > 0) {

        // Primeiro buscar onde esta a informacao

        size_t to_read_aux = to_read;

        void *data_block;

        void *block_of_blocks;

        while (to_read_aux > 0) {

            size_t current_block = file->of_offset / BLOCK_SIZE;

            size_t block_offset = file->of_offset % BLOCK_SIZE;

            size_t buffer_offset = to_read - to_read_aux;

            size_t buffer_size =
                to_read_aux > BLOCK_SIZE ? BLOCK_SIZE : to_read_aux;

            if (current_block < INODE_BLOCKS) {
                data_block =
                    data_block_get(inode->data_blocks_addr[current_block]);
            } else {
                block_of_blocks =
                    data_block_get(inode->data_blocks_addr[BLOCK_OF_BLOCKS]);

                if (block_of_blocks == NULL) {
                    return -1;
                }

                data_block =
                    data_block_get(*(int *)block_of_blocks +
                                   ((int)current_block - INODE_BLOCKS));
            }

            if (data_block == NULL) {
                return -1;
            }

            // Depois copiar a informacao

            memcpy(buffer + buffer_offset, data_block + block_offset,
                   buffer_size);

            // Incrementar variaveis necessarias

            to_read_aux -= buffer_size;

            file->of_offset += buffer_size;

            written += (ssize_t)buffer_size;
        }
    }

    return (ssize_t)written;
}

int tfs_copy_to_external_fs(const char *source_path, const char *dest_path) {

    char buffer[BUFFER_SIZE];

    int fhandle = tfs_lookup(source_path);
    if (fhandle == -1) {
        return -1;
    }

    FILE *ext_file = fopen(dest_path, "w");

    if (ext_file == NULL) {
        return -1;
    }

    if (tfs_read(fhandle, buffer, BUFFER_SIZE) == -1) {
        return -1;
    }
    while (strlen(buffer) > 0) {

        fwrite(buffer, sizeof(char), BUFFER_SIZE, ext_file);

        if (tfs_read(fhandle, buffer, BUFFER_SIZE) == -1) {
            return -1;
        }
    }

    tfs_close(fhandle);
    fclose(ext_file);

    return 1;
}