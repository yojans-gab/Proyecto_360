const conexion = require('../DBConection/db');

// Crear Orden con Detalles (solo usuarios con rol Cliente)
exports.createOrden = async (req, res) => {
    const pool = await conexion();
    const { idusuarios, rol_idrol } = req.user; // Datos del token
    const { detalles } = req.body;

    try {
        // Verificar si el rol es Cliente
        
        if (rol_idrol !== 1) { // Asume que el rol Cliente tiene idrol = 2
            return res.status(403).json({ msg: 'Solo los usuarios con rol Cliente pueden crear órdenes' });
        }

        // Convertir detalles a formato JSON
        const detallesJSON = JSON.stringify(detalles);

        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50);
             EXEC CrearOrdenConDetalles 
                @usuarios_idusuarios = :usuarios_idusuarios, 
                @detalles = :detallesJSON;
             SELECT @mensaje AS mensaje;`,
            {
                replacements: {
                    usuarios_idusuarios: idusuarios,
                    detallesJSON,
                },
            }
        );

        const mensaje = result[0]?.mensaje;
        res.json({ msg: mensaje });
    } catch (error) {
        console.error('Error al crear la orden:', error);
        res.status(500).json({ error: 'Error al crear la orden' });
    } finally {
        await pool.close();
    }
};

// Obtener Órdenes (solo las del usuario actual)
exports.getOrdenes = async (req, res) => {
    const pool = await conexion();
    const { idusuarios } = req.user; // Datos del token

    try {
        const [ordenes] = await pool.query(
            'SELECT * FROM Orden WHERE usuarios_idusuarios = :idusuarios',
            { replacements: { idusuarios } }
        );

        res.status(200).json({ msg: 'Órdenes encontradas', ordenes });
    } catch (error) {
        console.error('Error al obtener las órdenes:', error);
        res.status(500).json({ msg: 'Error al obtener las órdenes' });
    } finally {
        await pool.close();
    }
};

// Actualizar Órdenes (solo el creador puede actualizar)
exports.updateOrden = async (req, res) => {
    const pool = await conexion();
    const { id } = req.params;
    const { idusuarios } = req.user; // Datos del token
    const { detalles } = req.body;

    try {
        // Verificar si el usuario es el creador de la orden
        const [orden] = await pool.query(
            'SELECT usuarios_idusuarios FROM Orden WHERE idOrden = :id',
            { replacements: { id } }
        );

        if (!orden.length || orden[0].usuarios_idusuarios !== idusuarios) {
            return res.status(403).json({ msg: 'No tienes permiso para actualizar esta orden' });
        }

        // Actualizar orden
        const detallesJSON = JSON.stringify(detalles);

        const [result] = await pool.query(
            `DECLARE @mensaje NVARCHAR(50);
             EXEC ActualizarOrden 
                @idOrden = :id, 
                @usuarios_idusuarios = :usuarios_idusuarios, 
                @detalles = :detalles;
             SELECT @mensaje AS mensaje;`,
            {
                replacements: {
                    id,
                    usuarios_idusuarios: idusuarios,
                    detalles: detallesJSON,
                },
            }
        );

        const mensaje = result[0]?.mensaje;
        res.json({ msg: mensaje });
    } catch (error) {
        console.error('Error al actualizar la orden:', error);
        res.status(500).json({ error: 'Error al actualizar la orden' });
    } finally {
        await pool.close();
    }
};
