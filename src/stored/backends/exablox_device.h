/*
   BAREOS® - Backup Archiving REcovery Open Sourced

   Copyright (C) 2013-2013 Planets Communications B.V.
   Copyright (C) 2013-2013 Bareos GmbH & Co. KG

   This program is Free Software; you can redistribute it and/or
   modify it under the terms of version three of the GNU Affero General Public
   License as published by the Free Software Foundation, which is
   listed in the file LICENSE.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
   02110-1301, USA.
*/
/*
 * Originated from:
 *	UNIX File API device abstraction.
 *	Marco van Wieringen, June 2014
 * 
 * Modifications from Tad Hunt <tad@exablox.com>
 */

#ifndef EXABLOX_DEVICE_H
#define EXABLOX_DEVICE_H

class exablox_device: public DEVICE {
private:
   char e_dpath[PATH_MAX];
   char e_mpath[PATH_MAX];
   int  e_mdfd;                        /* Metadata File descriptor, where to dump metatadata */
   int  e_datafd;                      /* Data File descriptor, where to dump payload */

public:
   exablox_device();
   ~exablox_device();

   /*
    * Interface from DEVICE
    */
   bool		mount_backend(DCR *dcr, int timeout);
   bool		unmount_backend(DCR *dcr, int timeout);
   int		d_close(int);
   int		d_open(const char *pathname, int flags, int mode);
   int		d_ioctl(int fd, ioctl_req_t request, char *mt = NULL);
   boffset_t	d_lseek(DCR *dcr, boffset_t offset, int whence);
   ssize_t	d_read(int fd, void *buffer, size_t count);
   ssize_t	d_write(int fd, const void *buffer, size_t count);
   bool		d_truncate(DCR *dcr);
};
#endif /* EXABLOX_DEVICE_H */
