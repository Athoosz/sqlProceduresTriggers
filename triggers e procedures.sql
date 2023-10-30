create database sacolas;

use sacolas;


select * from sacola;



DELIMITER $$

create procedure excluir_bola_da_sacola (in color varchar(10))
begin
  delete from 
    sacola  
  where
    tipo_bola = color;
end

$$ DELIMITER ;



DELIMITER $$

create procedure inserir_bola_sacola (
 in color varchar(10),
 in quantity int
 )
 begin
 
    declare capacidade_sacola int default 100; 	
    declare quantidade_existente int default 0;
    declare bola_existe int default 0; -- ZERO = FALSE
    
    select 
      sum(quantidade)
      into quantidade_existente
    from sacola;
    
    select 
      ifnull(quantidade,0)
      into bola_existe
	from 
      sacola
     where
	  tipo_bola = color;
    
    if quantity >= 1 then
    
       if ((quantidade_existente + quantity) <= capacidade_sacola) and (bola_existe = 0)then
          insert into sacola (tipo_bola,quantidade)
            values (color,quantity);
       else
          select '** Voce Ultrapassou a quantidade limite**' as result;
            end if;
     else
     select '**O valor inserido é invalido, insira novamente**' as result;
        end if;
end
 
$$ DELIMITER ;



DELIMITER $$

create procedure alterar_quantidade_de_bolas_na_sacola (
  in color varchar(10),
  in quantity int
)

  begin
     declare capacidade_sacola int default 100;    -- capacidade de bola dentro da sacola
     declare quantidade_existente int default 0;   -- quantidade de bolas existentes na sacola
     declare quantidade_bola int default 0;        -- quantidade de bola existente
     declare bola_existe int default 0;            -- verifica a existencia da bola
     
     
     /* Identifica a existencia da bola na sacola*/
     select
       ifnull(quantidade,0)
       into bola_existe
	 from
       sacola
	 where
       tipo_bola = color;
     
     -- identifica a quantidade de bolas a serem atualizadas
    set quantidade_bola = bola_existe + quantity;
    
    if quantity >= 1 then 
    
      -- valida a existencia da bola
      if bola_existe <> 0 then
           if (quantidade_existente + quantidade_bola) <= capacidade_sacola then
              update sacola set quantidade = quantidade_bola
                 where tipo_bola = color;
		   else
               select '** Voce Ultrapassou a quantidade limite**' as result;
               end if;
         else
	      -- chamar a procedure de inserir bola na sacola
           call inserir_bola_sacola(color,quantity);
           end if;
       else 
         call excluir_bola_da_sacola(color);
      end if;
    
end

$$ DELIMITER ;


select * from sacola;
select sum(quantidade) from sacola;

call inserir_bola_sacola('Verde',93);

call alterar_quantidade_de_bolas_na_sacola('Verde',10);

call excluir_bola_da_sacola('Verde');





create table log(
id_log int primary key auto_increment,
data_modificacao timestamp not null,
descricao varchar(200) not null
);

delimiter $$
create trigger sacola_insert after 
insert on sacola for each row 
begin 
   insert into log values 
   (default,current_timestamp,CONCAT('registro inserido na tabela sacola',' ',new.tipo_bola,' ',new.quantidade));
   end
$$ delimiter ;


delimiter $$
create trigger sacola_update after 
update on sacola for each row 
begin 
   insert into log values 
   (default,current_timestamp,CONCAT('Bola antiga: ',old.tipo_bola,' ',new.tipo_bola,' ','Tipo antigo: ',old.quantidade,' ',new.quantidade));
   end
$$ delimiter ;

delimiter $$
create trigger sacola_delete after 
delete on sacola for each row 
begin 
   insert into log values 
   (default,current_timestamp,
   CONCAT('Valores excluidos: ',old.tipo_bola,' ', old.quantidade));
   end
$$ delimiter ;



select * from sacola;

select * from log;

call inserir_bola_sacola('azulclaro',50);

call alterar_quantidade_de_bolas_na_sacola('azulclaro',10);

call excluir_bola_da_sacola('azulclaro');






