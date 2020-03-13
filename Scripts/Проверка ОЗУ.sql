select *
from SRV.inf.vRAM
where ([StateMemoryServer]<>'Normal'
or [StateMemorySQL]<>'Normal')
and ([Server_physical_memory_Mb]>[SQL_server_committed_target_Mb]+4096)
--where SQL_RAM_Reserve_Percent>90--<80